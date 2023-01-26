//
//  AuthRequestManager.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import AppAuth

/*
 * An abstraction to deal with differences between providers
 */
protocol AuthRequestManagerProtocol {
    
    // Return the begin browser session request object
    func getBrowserLoginRequest() -> OIDAuthorizationRequest
    
    // Return the request to load the profile management page
    func getProfileManagementRequest() -> OIDAuthorizationRequest
    
    // Return the end browser session request object
    func getBrowserLogoutRequest() -> OIDEndSessionRequest
    
    // Return the refresh token request
    func getRefreshTokenRequest(refreshToken: String) -> OIDTokenRequest
    
    // Return the request to revoke a token
    func getRevokeTokenRequest(token: String) -> URLRequest?
    
    // Return the request to make the api call for the user info
    func getUserInfoRequest(accessToken: String) -> URLRequest?
}

/*
 * Logout manager for browser session
 */
struct AuthRequestManager: AuthRequestManagerProtocol {
    
    private let metadata: OIDServiceConfiguration
    
    init(_ metadata: OIDServiceConfiguration) {
        self.metadata = metadata
    }
    
    /*
     * Return the begin browser session request object
     */
    func getBrowserLoginRequest() -> OIDAuthorizationRequest {
        
        // Build the login request and include extra vendor specific parameters
        return OIDAuthorizationRequest(
            configuration: metadata,
            clientId: AuthConfig.clientId,
            clientSecret: "",
            scopes: AuthConfig.scopes,
            redirectURL: AuthConfig.redirectUrl,
            responseType: OIDResponseTypeCode,
            additionalParameters: AuthConfig.additionalParameters)
    }
    
    /*
     * Return the profile management request object
     */
    func getProfileManagementRequest() -> OIDAuthorizationRequest {
        
        let profileMangementMetadata = getProfileManagementMetadata()
        
        // Build the profile management request and include extra vendor specific parameters
        return OIDAuthorizationRequest(
            configuration: profileMangementMetadata,
            clientId: AuthConfig.clientId,
            clientSecret: "",
            scopes: AuthConfig.scopes,
            redirectURL: AuthConfig.redirectUrl,
            responseType: OIDResponseTypeCode,
            additionalParameters: AuthConfig.additionalParameters)
    }
    
    /*
     * Create updated metadata object with custom profile management URL
     */
    private func getProfileManagementMetadata() -> OIDServiceConfiguration {
        return OIDServiceConfiguration(
            authorizationEndpoint: AuthConfig.profileManagementUrl,
            tokenEndpoint: metadata.tokenEndpoint,
            issuer: metadata.issuer,
            registrationEndpoint: metadata.registrationEndpoint,
            endSessionEndpoint: metadata.endSessionEndpoint)
    }

    /*
     * Return the end browser session request object
     */
    func getBrowserLogoutRequest() -> OIDEndSessionRequest {
        
        let logoutMetadata = getLogoutMetadata()

        // Build the logout request and include extra vendor specific parameters
        return OIDEndSessionRequest(
            configuration: logoutMetadata,
            idTokenHint: "",
            postLogoutRedirectURL: AuthConfig.redirectUrl,
            state: "",
            additionalParameters: [:])
    }
    
    /*
     * Create updated metadata object with custom logout URL to end browser session
     */
    private func getLogoutMetadata() -> OIDServiceConfiguration {
        return OIDServiceConfiguration(
            authorizationEndpoint: metadata.authorizationEndpoint,
            tokenEndpoint: metadata.tokenEndpoint,
            issuer: metadata.issuer,
            registrationEndpoint: metadata.registrationEndpoint,
            endSessionEndpoint: AuthConfig.customLogoutUrl)
    }
    
    func getRefreshTokenRequest(refreshToken: String) -> OIDTokenRequest {
        
        // Create the refresh token grant request
        return OIDTokenRequest(
            configuration: metadata,
            grantType: OIDGrantTypeRefreshToken,
            authorizationCode: nil,
            redirectURL: nil,
            clientID: AuthConfig.clientId,
            clientSecret: nil,
            scope: nil,
            refreshToken: refreshToken,
            codeVerifier: nil,
            additionalParameters: nil)
    }
    
    func getRevokeTokenRequest(token: String) -> URLRequest? {
        
        var urlRequest = URLRequest(url: AuthConfig.revokeTokenUrl)
        urlRequest.httpMethod = "POST"
        
        let bodyString = "token=\(token)&client_id=\(AuthConfig.clientId)"
        let bodyData = bodyString.data(using: .utf8)!
        let bodyLength = "\(bodyData.count)"
        urlRequest.httpBody = bodyData
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(bodyLength, forHTTPHeaderField: "Content-Length")
        
        return urlRequest
    }
    
    func getUserInfoRequest(accessToken: String) -> URLRequest? {
        
        guard let discoveryDoc = metadata.discoveryDocument,
              let userInfoUrl = discoveryDoc.userinfoEndpoint
        else {
            return nil
        }

        var urlRequest = URLRequest(url: userInfoUrl)
        urlRequest.allHTTPHeaderFields = ["Authorization":"Bearer \(accessToken)"]
        
        return urlRequest
    }
}
