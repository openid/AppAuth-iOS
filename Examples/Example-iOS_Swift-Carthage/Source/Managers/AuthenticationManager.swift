//
//  AuthenticationManager.swift
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

protocol AuthenticationManagerDelegate: AnyObject {
    func logMessage(_ message: String?)
}

/*
 * An abstraction to represent authentication related operations
 */
protocol AuthenticationManagerProtocol {
    
    typealias CompletionHandler = (Result<String?, AuthError>) -> Void
    typealias CompletionAuthFlow = (OIDExternalUserAgentSession) -> Void
    typealias CompletionUserInfo = (Result<String?, AuthError>) -> Void
    
    var authStateManager: AuthStateManager { get }
    var metadata: OIDServiceConfiguration? { get }
    
    // Retrieve OpenID connect metadata
    func discoverConfig(_ completion: @escaping CompletionHandler)
    
    // Refresh the current access token
    func refreshAccessToken(_ completion: @escaping CompletionHandler)
    
    // Start a login redirect on the main thread
    func startBrowserLogin(_ currentAuthorizationFlow: @escaping CompletionAuthFlow, _ completion: @escaping CompletionHandler)
    
    // Start a login redirect where a manual code exchange is still required
    func startBrowserLoginWithManualCodeExchange(_ currentAuthorizationFlow: @escaping CompletionAuthFlow, _ completion: @escaping CompletionHandler)
    
    // Start a logout redirect on the main thread
    func startBrowserLogout(_ currentAuthorizationFlow: @escaping CompletionAuthFlow, _ completion: @escaping CompletionHandler)
    
    // Call web service to revoke token
    func expireToken(tokenType: TokenType, _ completion: @escaping CompletionHandler)
    
    // Perform the authorization code exchange
    func performCodeExchange(_ completion: @escaping CompletionHandler)
}

/*
 * The class for handling OAuth operations
 */
class AuthenticationManager: AuthenticationManagerProtocol {
    
    var authStateManager = AuthStateManager()
    private var rootViewController: UIViewController
    var metadata: OIDServiceConfiguration?
    private var authRequestManager: AuthRequestManager?
    private var webServiceManager = WebServiceManager()
    private var currentOAuthSession: OIDExternalUserAgentSession?
    
    private var authState: OIDAuthState? {
        return authStateManager.authState
    }
    
    weak var delegate: AuthenticationManagerDelegate?
    
    init(_ rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        authStateManager.loadAuthState()
    }
    
    /*
     * Request the OAuth service metadata from the URL specified in the AuthConfig
     */
    func discoverConfig(_ completion: @escaping CompletionHandler) {
        
        // Try to download metadata
        OIDAuthorizationService.discoverConfiguration(forDiscoveryURL: AuthConfig.discoveryUrl) { metadata, error in
            
            if let metadata = metadata {
                print("Metadata discovered: \(metadata)")
                self.metadata = metadata
                self.createAuthRequestManager(metadata: metadata)
                completion(.success(nil))
            } else {
                completion(.failure(AuthError(.configurationError)))
            }
        }
    }
    
    func appSessionLogout() {
        authStateManager.setAuthState(nil)
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
    func startBrowserLogin(_ currentAuthorizationFlow: @escaping CompletionAuthFlow, _ completion: @escaping CompletionHandler) {
        
        // Making authorization request.
        print("Initiating authorization request")
        
        guard let loginRequest = authRequestManager?.getBrowserLoginRequest() else {
            completion(.failure(AuthError(.loginRequestFailed)))
            return
        }
        
        currentAuthorizationFlow(OIDAuthState.authState(byPresenting: loginRequest, presenting: rootViewController) { authState, error in
            
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
                
                completion(.failure(AuthError(.loginRequestFailed, error: error)))
            } else {
                if let authState = authState {
                    self.authStateManager.setAuthState(authState)
                    self.authStateManager.isBrowserSessionActive = true
                    completion(.success(nil))
                }
            }
        })
    }
    
    /*
     * Performs the browser authorization flow.
     *
     * Attempts to perform a request to authorization endpoint by utilizing AppAuth's convenience method.
     *
     * The authorization code is returned and a manual code exchange can be done.
     *
     */
    func startBrowserLoginWithManualCodeExchange(_ currentAuthorizationFlow: @escaping CompletionAuthFlow, _ completion: @escaping CompletionHandler) {
        
        // Making authorization request.
        print("Initiating authorization request")
        
        guard let loginRequest = authRequestManager?.getBrowserLoginRequest() else {
            completion(.failure(AuthError(.loginRequestFailed)))
            return
        }
        
        currentAuthorizationFlow(OIDAuthorizationService.present(
            loginRequest,
            presenting: rootViewController) { response, error in
                
            if let response = response {
                print("Authorization response with code: \(response.authorizationCode ?? "DEFAULT_CODE")")
                
                let authState = OIDAuthState(authorizationResponse: response)
                self.authStateManager.setAuthState(authState)
                self.authStateManager.isBrowserSessionActive = true
                completion(.success(nil))
            } else {
                print("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                completion(.failure(AuthError(.loginRequestFailed, error: error)))
            }
        })
    }
    
    /*
     * Performs the loading of the profile management in the browser
     *
     * Attempts to perform a request to authorization endpoint by utilizing AppAuth's convenience method.
     *
     */
    func startProfileManagement(_ currentAuthorizationFlow: @escaping CompletionAuthFlow, _ completion: @escaping CompletionHandler) {
        
        // Making authorization request.
        print("Initiating authorization request")
        
        guard let loginRequest = authRequestManager?.getProfileManagementRequest() else {
            completion(.failure(AuthError(.profileManagementRequestFailed)))
            return
        }
        
        guard let agent = OIDExternalUserAgentIOS(presenting: rootViewController) else {
            completion(.failure(AuthError(.generalUIError)))
            return
        }
        
        currentAuthorizationFlow(OIDAuthorizationService.present(loginRequest, externalUserAgent: agent) {
            response, error in
            
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
                completion(.failure(AuthError(.profileManagementRequestFailed, error: error)))
            } else {
                completion(.success(nil))
            }
        })
    }
    
    func startBrowserLogout(_ currentAuthorizationFlow: @escaping CompletionAuthFlow, _ completion: @escaping CompletionHandler) {
        
        // Build the end session request
        guard let logoutRequest = authRequestManager?.getBrowserLogoutRequest() else {
            completion(.failure(AuthError(.configurationError)))
            return
        }
        
        guard let agent = OIDExternalUserAgentIOS(presenting: rootViewController) else {
            completion(.failure(AuthError(.generalUIError)))
            return
        }
        
        // Do the logout redirect
        currentAuthorizationFlow(OIDAuthorizationService.present(logoutRequest, externalUserAgent: agent) {
            response, error in
            
            if let error = error {
                completion(.failure(AuthError(.logoutRequestFailed, error: error)))
            } else {
                self.authStateManager.isBrowserSessionActive = false
                completion(.success(nil))
            }
        })
    }
    
    /*
     * The authorization code grant runs on a background thread
     */
    func performCodeExchange(_ completion: @escaping CompletionHandler) {
        
        guard let request = authStateManager.authState?.lastAuthorizationResponse.tokenExchangeRequest() else {
            completion(.failure(AuthError(.codeExchangeFailed)))
            return
        }
        
        OIDAuthorizationService.perform(request) { tokenResponse, error in
            
            if error != nil {
                completion(.failure(AuthError(.codeExchangeFailed, error: error)))
                return
            }
            
            if let tokenResponse = tokenResponse {
                
                // Save the Auth State to storage
                self.authStateManager.authState?.update(with: tokenResponse, error: error)
            }
            
            completion(.success(nil))
        }
    }
    
    /*
     * A method to do the work of the refresh token grant
     */
    func refreshAccessToken(_ completion: @escaping CompletionHandler) {
        
        guard let refreshToken = authStateManager.authState?.refreshToken else {
            completion(.failure(AuthError(.refreshTokenError)))
            return
        }
        
        guard let tokenRequest = authRequestManager?.getRefreshTokenRequest(refreshToken: refreshToken) else {
            completion(.failure(AuthError(.refreshTokenGrantFailed)))
            return
        }
        
        OIDAuthorizationService.perform(tokenRequest) { tokenResponse, error in
            
            // Handle errors
            guard let tokenResponse = tokenResponse, let _ = tokenResponse.accessToken, error == nil else {
                let authError = AuthError(.refreshTokenGrantFailed, error: error)
                if authError.errorCode == OIDErrorCodeOAuth.invalidGrant.rawValue {
                    // If we get an invalid_grant error it means the refresh token has expired
                    // In this case clear tokens and return, which will trigger a login redirect
                    self.authStateManager.setAuthState(nil)
                }
                
                completion(.failure(authError))
                return
            }
            
            self.authStateManager.authState?.update(with: tokenResponse, error: error)
            completion(.success(nil))
        }
    }
    
    func expireToken(tokenType: TokenType, _ completion: @escaping CompletionHandler) {
        
        var token: String?
        
        switch tokenType {
        case .accessToken:
            token = authStateManager.authState?.lastTokenResponse?.accessToken
        case .refreshToken:
            token = authStateManager.authState?.lastTokenResponse?.refreshToken
        }
        
        guard let token = token else {
            completion(.failure(AuthError(.tokenError, tokenType)))
            return
        }
        
        guard let urlRequest = authRequestManager?.getRevokeTokenRequest(token: token) else {
            completion(.failure(AuthError(.tokenError, tokenType)))
            return
        }
        
        webServiceManager.sendUrlRequest(urlRequest) { result in
            
            switch result {
            case .success:
                switch tokenType {
                case .accessToken:
                    self.authStateManager.isAccessTokenActive = false
                case .refreshToken:
                    self.authStateManager.isRefreshTokenActive = false
                }
                
                completion(.success(nil))
            case .failure(let error):
                completion(.failure(AuthError(.tokenError, error: error, tokenType)))
            }
        }
        
    }
    
    func getUserInfo(_ completion: @escaping CompletionUserInfo) {
        guard let accessToken = authStateManager.authState?.lastTokenResponse?.accessToken else {
            completion(.failure(AuthError(.accessTokenError)))
            return
        }
        
        // Validating and refreshing tokens
        authStateManager.authState?.performAction() { freshAccessToken, idToken, error in
            
            guard let freshAccessToken = freshAccessToken, error == nil else {
                completion(.failure(AuthError(.refreshTokenGrantFailed, error: error)))
                return
            }
            
            if freshAccessToken != accessToken {
                print("Access token was refreshed automatically (\(freshAccessToken) to \(accessToken))")
            } else {
                print("HTTP response data is empty. Access token was fresh and not updated \(accessToken)")
            }
            
            // Create user info request with the fresh access token
            guard let request = self.authRequestManager?.getUserInfoRequest(accessToken: freshAccessToken) else {
                completion(.failure(AuthError(.configurationError)))
                return
            }
            
            self.webServiceManager.sendUrlRequest(request) { result in
                
                switch result {
                case .success((let data, let response)):
                    guard let data = data else {
                        completion(.failure(AuthError(.responseParsingFailed, response: response)))
                        return
                    }
                    var json: [String: Any]?
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    } catch {
                        completion(.failure(AuthError(.responseParsingFailed, response: response)))
                    }
                    
                    completion(.success(json?.debugDescription))
                    
                case .failure(let error):
                    // "401 Unauthorized" generally indicates there is an issue with the authorization
                    // grant. Puts OIDAuthState into an error state.
                    if error.statusCode == 401 {
                        self.authStateManager.authState?.update(withAuthorizationError: error)
                    }
                    completion(.failure(AuthError(.apiResponseError, error: error)))
                }
            }
        }
    }
    
    /*
     * Return the authorization request manager for the active provider
     */
    private func createAuthRequestManager(metadata: OIDServiceConfiguration) {
        authRequestManager = AuthRequestManager(metadata)
    }
}

