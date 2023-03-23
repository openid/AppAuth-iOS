//
//  AuthRequestFactory.swift
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
    func browserLoginRequest(_ discoveryConfig: OIDServiceConfiguration) -> OIDAuthorizationRequest
    
    // Return the request to load the profile management page
    func profileManagementRequest(_ discoveryConfig: OIDServiceConfiguration) -> OIDAuthorizationRequest
    
    // Return the request to make the api call for the user info
    func userInfoRequest(_ discoveryConfig: OIDServiceConfiguration, accessToken: String) -> URLRequest?
    
    // Return the end browser session request object
    func browserLogoutRequest(_ discoveryConfig: OIDServiceConfiguration) -> OIDEndSessionRequest
    
    // Return the request to revoke a token
    func revokeTokenRequest(_ token: String) -> URLRequest?
}

/*
 * Factory for the authorization requests
 */
class AuthRequestFactory: AuthRequestFactoryProtocol {
    
    let authConfig: AuthConfigProtocol
    
    init(_ authConfig: AuthConfigProtocol) {
        self.authConfig = authConfig
    }
    
    /*
     * Return the begin browser session request object
     */
    func browserLoginRequest(_ discoveryConfig: OIDServiceConfiguration) -> OIDAuthorizationRequest {
        
        // Build the login request and include extra vendor specific parameters
        return OIDAuthorizationRequest(
            configuration: discoveryConfig,
            clientId: authConfig.clientId,
            clientSecret: "",
            scopes: authConfig.scopes,
            redirectURL: authConfig.redirectUrl,
            responseType: OIDResponseTypeCode,
            additionalParameters: authConfig.additionalParameters)
    }
    
    /*
     * Return the profile management request object
     */
    func profileManagementRequest(_ discoveryConfig: OIDServiceConfiguration) -> OIDAuthorizationRequest {
        
        let profileManagementMetadata = profileManagementMetadata(discoveryConfig)
        
        // Build the profile management request and include extra vendor specific parameters
        return OIDAuthorizationRequest(
            configuration: profileManagementMetadata,
            clientId: authConfig.clientId,
            clientSecret: "",
            scopes: authConfig.scopes,
            redirectURL: authConfig.redirectUrl,
            responseType: OIDResponseTypeCode,
            additionalParameters: authConfig.additionalParameters)
    }
    
    /*
     * Create updated metadata object with custom profile management URL
     */
    private func profileManagementMetadata(_ discoveryConfig: OIDServiceConfiguration) -> OIDServiceConfiguration {
        return OIDServiceConfiguration(
            authorizationEndpoint: authConfig.profileManagementUrl,
            tokenEndpoint: discoveryConfig.tokenEndpoint,
            issuer: discoveryConfig.issuer,
            registrationEndpoint: discoveryConfig.registrationEndpoint,
            endSessionEndpoint: discoveryConfig.endSessionEndpoint)
    }
    
    /*
     * Return the end browser session request object
     */
    func browserLogoutRequest(_ discoveryConfig: OIDServiceConfiguration) -> OIDEndSessionRequest {
        
        let logoutMetadata = logoutMetadata(discoveryConfig)
        
        let logoutAdditionalParams = [
            "client_id": authConfig.clientId
        ]
        
        // Build the logout request and include extra vendor specific parameters
        return OIDEndSessionRequest(
            configuration: logoutMetadata,
            idTokenHint: "",
            postLogoutRedirectURL: authConfig.redirectUrl,
            additionalParameters: logoutAdditionalParams)
    }
    
    /*
     * Create updated metadata object with custom logout URL to end browser session
     */
    private func logoutMetadata(_ discoveryConfig: OIDServiceConfiguration) -> OIDServiceConfiguration {
        return OIDServiceConfiguration(
            authorizationEndpoint: discoveryConfig.authorizationEndpoint,
            tokenEndpoint: discoveryConfig.tokenEndpoint,
            issuer: discoveryConfig.issuer,
            registrationEndpoint: discoveryConfig.registrationEndpoint,
            endSessionEndpoint: authConfig.customLogoutUrl)
    }
    
    func revokeTokenRequest(_ token: String) -> URLRequest? {
        
        var urlRequest = URLRequest(url: authConfig.revokeTokenUrl)
        urlRequest.httpMethod = "POST"
        
        let bodyString = "token=\(token)&client_id=\(authConfig.clientId)"
        let bodyData = bodyString.data(using: .utf8)!
        let bodyLength = "\(bodyData.count)"
        urlRequest.httpBody = bodyData
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(bodyLength, forHTTPHeaderField: "Content-Length")
        
        return urlRequest
    }
    
    func userInfoRequest(_ discoveryConfig: OIDServiceConfiguration, accessToken: String) -> URLRequest? {
        
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
