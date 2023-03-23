//
//  Authenticator.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import AppAuth

/*
 * The class for handling OAuth operations
 */
class Authenticator: AuthenticatorProtocol {
    
    let rootViewController: UIViewController
    weak var delegate: AuthenticatorDelegate?
    
    private(set) var authConfig: AuthConfigProtocol
    private(set) var OIDAuthState: AuthStateStaticBridge.Type
    private(set) var OIDAuthorizationService: AuthorizationServiceStaticBridge.Type
    
    private(set) var authStateManager: AuthStateManagerProtocol
    private(set) var webServiceManager: WebServiceManagerProtocol
    
    private(set) var loginResponseHandler: LoginResponseHandlerProtocol
    private(set) var logoutResponseHandler: LogoutResponseHandlerProtocol
    private(set) var authStateResponseHandler: AuthStateResponseHandlerProtocol
    private(set) var authRequestFactory: AuthRequestFactoryProtocol
    
    required init(_ authConfig: AuthConfigProtocol,
                  rootViewController: UIViewController,
                  authStateManager: AuthStateManagerProtocol,
                  webServiceManager: WebServiceManagerProtocol = WebServiceManager(),
                  loginResponseHandler: LoginResponseHandlerProtocol = LoginResponseHandler(),
                  logoutResponseHandler: LogoutResponseHandlerProtocol = LogoutResponseHandler(),
                  authStateResponseHandler: AuthStateResponseHandlerProtocol = AuthStateResponseHandler(),
                  OIDAuthState: AuthStateStaticBridge.Type,
                  OIDAuthorizationService: AuthorizationServiceStaticBridge.Type) {
        
        self.authConfig = authConfig
        self.rootViewController = rootViewController
        
        self.authStateManager = authStateManager
        self.webServiceManager = webServiceManager
        self.loginResponseHandler = loginResponseHandler
        self.logoutResponseHandler = logoutResponseHandler
        self.authStateResponseHandler = authStateResponseHandler
        
        self.OIDAuthState = OIDAuthState.self
        self.OIDAuthorizationService = OIDAuthorizationService.self
        
        authRequestFactory = AuthRequestFactory(authConfig)
    }
    
    // MARK: Computed Authorization Properties
    
    var discoveryConfig: OIDServiceConfiguration?
    
    // Return the Discovery Config string for logging
    var discoveryConfigString: String? {
        discoveryConfig?.description
    }
    
    // True if login was performed with manual code exchange
    var isCodeExchangeRequired = false
    
    // Return the authorization state of the stored AuthState
    var isAuthStateActive: Bool {
        authStateManager.authorizationState == .active
    }
    
    // Return whether or not the user is authenticated in the browser
    var isBrowserSessionActive: Bool {
        authStateManager.browserState == .active
    }
    
    var lastAuthResponse: OIDAuthorizationResponse? {
        authStateManager.lastAuthorizationResponse
    }
    
    var tokenExchangeRequest: OIDTokenRequest? {
        authStateManager.tokenExchangeRequest
    }
    
    // Returns the token request from the
    // last authorization response if it exists
    var lastTokenResponse: OIDTokenResponse? {
        authStateManager.lastTokenResponse
    }
    
    // Refresh the tokens then return an access token if one exists
    var accessToken: String? {
        authStateManager.accessToken
    }
    
    // Returns the refresh token stored in the AuthState if it exists
    var refreshToken: String? {
        authStateManager.refreshToken
    }
    
    var isAccessTokenRevoked: Bool {
        authStateManager.accessTokenState == .inactive
    }
    
    var isRefreshTokenRevoked: Bool {
        authStateManager.refreshTokenState == .inactive
    }
}

extension Authenticator {
    
    /*
     * Download discovery doc metadata
     */
    func loadDiscoveryConfig() async throws -> String {
        
        return try await withCheckedThrowingContinuation { continuation in
            
            // Try to download metadata
            OIDAuthorizationService.discoverConfiguration(forIssuer: authConfig.discoveryUrl) { metadata, error in
                
                guard let metadata = metadata else {
                    let authError = AuthError.api(message: AuthError.noDiscoveryDoc.localizedDescription, underlyingError: error)
                    continuation.resume(throwing: authError)
                    return
                }
                self.discoveryConfig = metadata
                continuation.resume(returning: metadata.description)
            }
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
                } else {
                    
                    guard let response = response, let _ = response.accessToken else {
                        continuation.resume(throwing: AuthError.errorFetchingFreshTokens)
                        return
                    }
                    
                    // Save received tokens and return success
                    self.delegate?.logMessage("Token response: \(response.debugDescription)")
                    self.authStateManager.updateWithTokenResponse(response, error: nil)
                    continuation.resume()
                }
            }
        }
    }
    
    func revokeToken(tokenType: TokenType) async throws {
        let token = tokenType == .accessToken ? authStateManager.accessToken : authStateManager.refreshToken
        
        guard let token = token,
              let request = authRequestFactory.revokeTokenRequest(token) else {
            
            throw AuthError.noTokens
        }
        
        delegate?.logMessage("Revoke token request: \(request.debugDescription)")
        print("Revoking \(tokenType.rawValue): \(token)")
        
        let _ = try await webServiceManager.sendUrlRequest(request)
        
        authStateManager.setTokenState(tokenType, state: .inactive)
        delegate?.logMessage("Successfully revoked \(tokenType.rawValue): \(token)")
    }
    
    func performUserInfoRequest() async throws -> String {
        
        guard let discoveryConfig = discoveryConfig else {
            throw AuthError.noDiscoveryDoc
        }
        
        try await refreshTokens()
        
        guard let freshAccessToken = authStateManager.accessToken else {
            throw AuthError.errorFetchingFreshTokens
        }
        guard let request = authRequestFactory.userInfoRequest(discoveryConfig, accessToken: freshAccessToken) else {
            throw AuthError.errorFetchingFreshTokens
        }
        
        delegate?.logMessage("Performing the user info request: \(request)")
        let data = try await webServiceManager.sendUrlRequest(request)
        guard let dataString = try webServiceManager.getStringFromResponse(data) else {
            throw AuthError.parseFailure
        }
        
        return dataString
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
        
        guard let discoveryConfig = discoveryConfig else { throw AuthError.noDiscoveryDoc }
        
        // Making authorization request.
        print("Initiating authorization request with auto code exchange")
        let request = authRequestFactory.browserLoginRequest(discoveryConfig)
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
        
        guard let discoveryConfig = discoveryConfig else { throw AuthError.noDiscoveryDoc }
        
        // Making authorization request.
        print("Initiating authorization request with manual code exchange")
        
        let request = authRequestFactory.browserLoginRequest(discoveryConfig)
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
        } catch let error as NSError where error.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue {
            throw AuthError.userCancelledAuthorizationFlow
        } catch {
            throw AuthError.api(message: error.localizedDescription, underlyingError: error)
        }
    }
    
    func finishLoginWithAuthResponse(_ authResponse: OIDAuthorizationResponse?) async throws {
        if let authResponse = authResponse {
            let authStateResponse = AppAuth.OIDAuthState(authorizationResponse: authResponse, tokenResponse: nil)
            
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
        
        guard let lastAuthResponse = lastAuthResponse, let tokenExchangeRequest = tokenExchangeRequest else {
            throw AuthError.unableToGetAuthCode
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            OIDAuthorizationService.perform(
                tokenExchangeRequest,
                originalAuthorizationResponse: lastAuthResponse) { response, error in
                    if error != nil {
                        // Throw errors
                        let authError = AuthError.unableToGetAuthCode
                        continuation.resume(throwing: authError)
                        return
                    }
                    
                    self.delegate?.logMessage("Authorization code exchange response: \(response.debugDescription)")
                    
                    // Save the tokens to storage
                    self.authStateManager.updateWithTokenResponse(response, error: nil)
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
        
        guard let discoveryConfig = discoveryConfig else { throw AuthError.noDiscoveryDoc }
        
        // Making request to load the profile management page in the browser
        print("Initiating profile management request")
        
        let request = authRequestFactory.profileManagementRequest(discoveryConfig)
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
        
        guard let discoveryConfig = discoveryConfig else { throw AuthError.noDiscoveryDoc }
        
        // Making logout request
        print("Initiating logout request")
        
        let request = authRequestFactory.browserLogoutRequest(discoveryConfig)
        delegate?.logMessage("Logout request: \(request)")
        
        // Do the logout redirect
        guard let agent = OIDExternalUserAgentIOS(presenting: rootViewController) else {
            throw AuthError.externalAgentFailed
        }
        
        return OIDAuthorizationService.present(
            request,
            externalUserAgent: agent,
            callback: logoutResponseHandler.callback)
    }
    
    /*
     * Process the logout response and free resources
     */
    func handleBrowserLogoutResponse() async throws -> OIDEndSessionResponse {
        
        do {
            return try await logoutResponseHandler.waitForCallback()
        } catch let error as NSError where error.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue {
            throw AuthError.userCancelledAuthorizationFlow
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
