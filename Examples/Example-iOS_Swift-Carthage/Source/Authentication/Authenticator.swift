//
//  Authenticator.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import AppAuth

enum TokenType: String {
    case accessToken = "Access Token"
    case refreshToken = "Refresh Token"
}

protocol AuthenticatorDelegate: AnyObject {
    func logMessage(_ message: String)
}

protocol AuthenticatorProtocol {
    var discoveryConfig: OIDServiceConfiguration? { get }
}

/*
 * The class for handling OAuth operations
 */
class Authenticator {
    
    weak var delegate: AuthenticatorDelegate?
    
    var discoveryConfig: OIDServiceConfiguration?
    
    let rootViewController: UIViewController
    private(set) var authStateManager = AuthStateManager()
    
    private(set) lazy var loginResponseHandler = LoginResponseHandler()
    private(set) lazy var logoutResponseHandler = LogoutResponseHandler()
    private(set) lazy var authStateResponseHandler = AuthStateResponseHandler()
    private(set) lazy var concurrencyHandler = ConcurrencyHandler()
    private(set) lazy var requestFactory = AuthRequestFactory(discoveryConfig!)
    
    init(_ rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        
        authStateManager.loadAuthState()
        authStateManager.loadBrowserState()
    }
    
    // MARK: Computed Authorization Properties
    
    // Return the authorization state of the stored AuthState
    var isAuthStateActive: Bool {
        return authStateManager.isAuthStateAuthorized
    }
    
    // Return whether or not the user is authenticated in the browser
    var isBrowserSessionActive: Bool {
        return authStateManager.browserState == .active
    }
    
    var isAccessTokenRevoked = false
    var isRefreshTokenRevoked = false
    
    // Returns the refresh token stored in the AuthState if it exists
    var refreshToken: String? {
        return authStateManager.refreshToken
    }
    
    // Returns the token request from the
    // last authorization response if it exists
    var lastTokenResponse: OIDTokenResponse? {
        return authStateManager.lastTokenResponse
    }
    
    // Returns the stored authorization code if it exists
    var authorizationCode: String? {
        return authStateManager.authorizationCode
    }
    
    var isCodeExchangeRequired = false
}

extension Authenticator {
    
    /*
     * Download discovery doc metadata
     */
    func getDiscoveryConfig(_ discoveryUrl: URL) async throws {
        
        if discoveryConfig != nil {
            return
        }
        
        // Do nothing if already loaded
        if let config = authStateManager.discoveryConfig {
            discoveryConfig = config
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            
            // Try to download metadata
            OIDAuthorizationService.discoverConfiguration(forIssuer: discoveryUrl) { metadata, error in
                
                if let metadata = metadata, error == nil {
                    self.discoveryConfig = metadata
                    continuation.resume()
                    return
                } else {
                    let authError = AuthError.api(message: AuthError.noDiscoveryDoc.errorDescription ?? "", underlyingError: error)
                    
                    continuation.resume(throwing: authError)
                    return
                }
            }
        }
    }
    
    // Returns the refresh token stored in the AuthState if it exists
    func getAccessToken() async throws -> String {
        
        do {
            try await concurrencyHandler.execute(action: refreshTokens)
            
            if let accessToken = authStateManager.accessToken {
                return accessToken
            } else {
                throw AuthError.noTokens
            }
            
        } catch {
            throw AuthError.api(message: error.localizedDescription, underlyingError: error)
        }
    }
    
    /*
     * Try to refresh an access token
     */
    func refreshTokens() async throws {
        guard let request = authStateManager.tokenRefreshRequest else {
            throw AuthError.noRefreshToken
        }
        
        delegate?.logMessage("Performing refresh token request: \(request.debugDescription)")
        
        return try await withCheckedThrowingContinuation { continuation in
            OIDAuthorizationService.perform(request) { response, error in
                // Handle errors
                if error != nil {
                    
                    self.authStateManager.updateWithTokenResponse(nil, error: error)
                    
                    if let error = error as? NSError, error.code == OIDErrorCodeOAuth.invalidGrant.rawValue {
                        continuation.resume(throwing: AuthError.errorFetchingFreshTokens)
                        return
                    }
                    
                    continuation.resume(throwing: AuthError.api(message: error?.localizedDescription ?? "", underlyingError: error))
                    return
                }
                
                // Make a sanity check to ensure we have tokens
                if response == nil || response!.accessToken == nil {
                    continuation.resume(throwing: AuthError.errorFetchingFreshTokens)
                    return
                }
                
                // Save received tokens and return success
                self.delegate?.logMessage("Token response: \(response.debugDescription)")
                self.authStateManager.updateWithTokenResponse(response, error: nil)
                self.isAccessTokenRevoked = false
                self.isRefreshTokenRevoked = false
                continuation.resume()
            }
        }
    }
    
    func revokeToken(tokenType: TokenType) async throws {
        do {
            let token = tokenType == .accessToken ? try await getAccessToken() : refreshToken

            print("Revoking \(tokenType.rawValue): \(token.debugDescription)")
            
            if let token = token,
                let request = requestFactory.revokeTokenRequest(token) {
                delegate?.logMessage("Revoke token request: \(request.debugDescription)")
                
                let (_, _) = try await WebServiceManager.sendUrlRequest(request)
                
                switch tokenType {
                case .accessToken:
                    isAccessTokenRevoked = true
                case .refreshToken:
                    isRefreshTokenRevoked = true
                }
            }
        } catch {
            throw AuthError.api(message: error.localizedDescription, underlyingError: error)
        }
    }
    
    func performUserInfoRequest() async throws -> String? {
        do {
            let accessToken = try await getAccessToken()
            guard let request = requestFactory.userInfoRequest(accessToken) else {
                throw AuthError.noBearerToken
            }
            
            delegate?.logMessage("Performing the user info request: \(request)")
            
            let (_, response) = try await WebServiceManager.sendUrlRequest(request)
            
            return response
            
        } catch {
            throw AuthError.api(message: error.localizedDescription, underlyingError: error)
        }
    }
    
    /*
     * Performs the authorization code flow.
     *
     * Attempts to perform a request to authorization endpoint by utilizing AppAuth's convenience method.
     *
     * Completes authorization code flow with automatic code exchange.
     *
     * The response is then passed to the completion handler, which lets the caller to handle the results.
     *
     */
    func startBrowserLoginWithAutoCodeExchange() throws -> OIDExternalUserAgentSession {
        
        // Making authorization request.
        print("Initiating authorization request with auto code exchange")
        
        let request = requestFactory.browserLoginRequest()
        delegate?.logMessage("Performing the authorization request: \(request.debugDescription)")
        // Do the redirect
        return OIDAuthState.authState(byPresenting: request,
                                      presenting: rootViewController,
                                      callback: authStateResponseHandler.callback)
    }
    
    /*
     * Complete login processing on a background thread
     */
    func handleBrowserLoginWithAutoCodeExchangeResponse() async throws -> OIDAuthState {
        do {
            return try await authStateResponseHandler.waitForCallback()
        } catch let error as NSError where error.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue {
            throw AuthError.userCancelledAuthorizationFlow
        } catch {
            throw AuthError.api(message: error.localizedDescription, underlyingError: error)
        }
    }
    
    func finishLoginWithAuthStateResponse(_ authState: OIDAuthState?) async throws {
        if let authState = authState {
            delegate?.logMessage("AuthState response: \(authState.debugDescription)")
            
            authStateManager.setAuthState(authState)
            authStateManager.setBrowserState(.active)
            isAccessTokenRevoked = false
            isRefreshTokenRevoked = false
            isCodeExchangeRequired = false
        } else {
            authStateManager.setAuthState(nil)
            authStateManager.setBrowserState(.inactive)
        }
    }
    
    /*
     * Performs the authorization code flow.
     *
     * Attempts to perform a request to authorization endpoint by utilizing AppAuth's convenience method.
     *
     * Completes authorization code flow without performing an authorization code exchange
     *
     * The response is then passed to the completion handler, which lets the caller to handle the results.
     *
     */
    func startBrowserLoginWithManualCodeExchange() throws -> OIDExternalUserAgentSession {
        
        // Making authorization request.
        print("Initiating authorization request with manual code exchange")
        
        let request = requestFactory.browserLoginRequest()
        delegate?.logMessage("Performing the authorization request: \(request.debugDescription)")
        
        // Do the redirect
        return OIDAuthorizationService.present(
            request,
            presenting: rootViewController,
            callback: loginResponseHandler.callback)
    }
    
    /*
     * Complete login processing on a background thread
     */
    func handleBrowserLoginWithManualCodeExchangeResponse() async throws -> OIDAuthorizationResponse {
        
        do {
            return try await loginResponseHandler.waitForCallback()
        } catch let error as NSError where error.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue{
                throw AuthError.userCancelledAuthorizationFlow
        } catch {
            throw AuthError.api(message: error.localizedDescription, underlyingError: error)
        }
    }
    
    func finishLoginWithAuthResponse(_ authResponse: OIDAuthorizationResponse?) async throws {
        if let authResponse = authResponse {
            let authStateResponse = OIDAuthState(authorizationResponse: authResponse, tokenResponse: nil)
            
            delegate?.logMessage("Authorization response: \(authStateResponse)")
            
            isCodeExchangeRequired = true
            authStateManager.setAuthState(authStateResponse)
            authStateManager.setBrowserState(.active)
        } else {
            authStateManager.setAuthState(nil)
            authStateManager.setBrowserState(.inactive)
        }
    }
    
    /*
     * The authorization code grant runs on a background thread
     */
    func exchangeAuthorizationCode() async throws {
        
        // Making authorization request.
        print("Initiating code exchange request")
        
        guard let authResponse = authStateManager.authState?.lastAuthorizationResponse, let tokenExchangeRequest = authResponse.tokenExchangeRequest() else {
            throw AuthError.unableToGetAuthCode
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            OIDAuthorizationService.perform(
                    tokenExchangeRequest,
                    originalAuthorizationResponse: authResponse) { response, error in
                        if error != nil {
                            // Throw errors
                            let authError = AuthError.unableToGetAuthCode
                            continuation.resume(throwing: authError)
                            return
                        }

                        self.delegate?.logMessage("Authorization code exchange response: \(response.debugDescription)")
                        
                        // Save the tokens to storage
                        self.authStateManager.updateWithTokenResponse(response, error: nil)
                        self.isRefreshTokenRevoked = false
                        self.isAccessTokenRevoked = false
                        self.isCodeExchangeRequired = false
                        continuation.resume()
                    }
            }
    }
    
    /*
     * Performs the authorization request to open the user's profile management in the browser
     *
     * The response is then passed to the completion handler, which lets the caller to handle the results.
     *
     */
    func startProfileManagementRedirect() throws -> OIDExternalUserAgentSession {
        
        // Making request to load the profile management page in the browser
        print("Initiating profile management request")
        
        let request = requestFactory.profileManagementRequest()
        delegate?.logMessage("Profile management request: \(request)")
        
        // Do the redirect
        return OIDAuthorizationService.present(
            request,
            presenting: rootViewController,
            callback: loginResponseHandler.callback)
    }
    
    func handleProfileManagementResponse() async throws {
        do {
            let response = try await loginResponseHandler.waitForCallback()
            delegate?.logMessage("Profile management response: \(response)")
            print(response.debugDescription)
            
        } catch let error as NSError {
            if error.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue {
                throw AuthError.userCancelledAuthorizationFlow
            }
        } catch {
            throw AuthError.api(message: error.localizedDescription, underlyingError: error)
        }
    }
    
    /*
     * The OAuth entry point for logout processing
     */
    func startBrowserLogoutRedirect() throws -> OIDExternalUserAgentSession {
        
        // Making logout request
        print("Initiating logout request")
        
        let request = requestFactory.browserLogoutRequest()
        delegate?.logMessage("Logout request: \(request)")
        
        // Do the logout redirect
        let agent = OIDExternalUserAgentIOS(presenting: rootViewController)
        return OIDAuthorizationService.present(
            request,
            externalUserAgent: agent!,
            callback: logoutResponseHandler.callback)
    }
    
    /*
     * Process the logout response and free resources
     */
    func handleBrowserLogoutResponse() async throws -> OIDEndSessionResponse {
        do {
           return try await self.logoutResponseHandler.waitForCallback()
        } catch {
            throw AuthError.api(message: error.localizedDescription, underlyingError: error)
        }
    }
    
    func finishBrowserLogout(_ response: OIDEndSessionResponse?) async throws {
        if let response = response {
            delegate?.logMessage("Browser logout response: \(response)")
            authStateManager.setBrowserState(.inactive)
        }
    }
    
    func performAppSessionLogout() async throws {
        // Clear the app authorization state
        authStateManager.setAuthState(nil)
    }
}
