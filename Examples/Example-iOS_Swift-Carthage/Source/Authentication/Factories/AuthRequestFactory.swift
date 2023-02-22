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
protocol AuthRequestFactoryProtocol {
    
    // Return the begin browser session request object
    func browserLoginRequest() -> OIDAuthorizationRequest
    
    // Return the request to load the profile management page
    func profileManagementRequest() -> OIDAuthorizationRequest
    
    // Return the request to make the api call for the user info
    func userInfoRequest(_ accessToken: String) -> URLRequest?
    
    // Return the end browser session request object
    func browserLogoutRequest() -> OIDEndSessionRequest
    
    // Return the request to revoke a token
    func revokeTokenRequest(_ token: String) -> URLRequest?
}

/*
 * Factory for the authorization requests
 */
class AuthRequestFactory: AuthRequestFactoryProtocol {
    
    private var discoveryConfig: OIDServiceConfiguration
    
    init(_ discoveryConfig: OIDServiceConfiguration) {
        self.discoveryConfig = discoveryConfig
    }
    
    /*
     * Return the begin browser session request object
     */
    func browserLoginRequest() -> OIDAuthorizationRequest {
        
        // Build the login request and include extra vendor specific parameters
        return OIDAuthorizationRequest(
            configuration: discoveryConfig,
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
    func profileManagementRequest() -> OIDAuthorizationRequest {
        
        let profileMangementMetadata = profileManagementMetadata()
        
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
    private func profileManagementMetadata() -> OIDServiceConfiguration {
        return OIDServiceConfiguration(
            authorizationEndpoint: AuthConfig.profileManagementUrl,
            tokenEndpoint: discoveryConfig.tokenEndpoint,
            issuer: discoveryConfig.issuer,
            registrationEndpoint: discoveryConfig.registrationEndpoint,
            endSessionEndpoint: discoveryConfig.endSessionEndpoint)
    }

    /*
     * Return the end browser session request object
     */
    func browserLogoutRequest() -> OIDEndSessionRequest {
        
        let logoutMetadata = logoutMetadata()
        
        let logoutAdditionalParams = [
            "client_id": AuthConfig.clientId
        ]

        // Build the logout request and include extra vendor specific parameters
        return OIDEndSessionRequest(
            configuration: logoutMetadata,
            idTokenHint: "",
            postLogoutRedirectURL: AuthConfig.redirectUrl,
            additionalParameters: logoutAdditionalParams)
    }
    
    /*
     * Create updated metadata object with custom logout URL to end browser session
     */
    private func logoutMetadata() -> OIDServiceConfiguration {
        return OIDServiceConfiguration(
            authorizationEndpoint: discoveryConfig.authorizationEndpoint,
            tokenEndpoint: discoveryConfig.tokenEndpoint,
            issuer: discoveryConfig.issuer,
            registrationEndpoint: discoveryConfig.registrationEndpoint,
            endSessionEndpoint: AuthConfig.customLogoutUrl)
    }
    
    func revokeTokenRequest(_ token: String) -> URLRequest? {
        
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
    
    func userInfoRequest(_ accessToken: String) -> URLRequest? {
        
        guard let discoveryDoc = discoveryConfig.discoveryDocument,
              let userInfoUrl = discoveryDoc.userinfoEndpoint
        else {
            return nil
        }

        var urlRequest = URLRequest(url: userInfoUrl)
        urlRequest.allHTTPHeaderFields = ["Authorization":"Bearer \(accessToken)"]
        
        return urlRequest
    }
}
