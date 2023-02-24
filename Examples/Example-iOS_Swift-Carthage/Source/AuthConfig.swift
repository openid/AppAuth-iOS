//
//  AuthConfig.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation

struct AuthConfig {
    
    // User defaults storage keys
    static let authStateStorageKey = "authState"
    static let browserStateStorageKey = "browserState"

    // The OAuth client id
    static let clientId: String = "cec9a504-a0ab-4b92-879b-711482a3f69b"
    
    // The base url for OAuth services
    private static let baseUrl: String = "https://api.multi.dev.or.janrain.com/00000000-0000-0000-0000-000000000000"
    
    // The OIDC issuer from which the configuration will be discovered
    private static let discoveryPath: String = "/login"
    static var discoveryUrl = URL(string: "\(baseUrl)\(discoveryPath)")!
    
    // The redirect URI for the mobile app
    static let redirectUriScheme: String = "net.openid.appauthdemo"
    static let redirectUriHost: String = "oauth2redirect"
    static var redirectUrl = URL(string: redirectUriScheme + "://" + redirectUriHost)!
    
    // The path for accessing profile management
    private static let profileManagementPath: String = "/auth-ui/profile"
    static var profileManagementUrl = URL(string: "\(baseUrl)\(profileManagementPath)")!
    
    // The custom browser session logout path
    private static let customLogoutPath: String = "/auth-ui/logout"
    static var customLogoutUrl = URL(string: "\(baseUrl)\(customLogoutPath)")!
    
    // The path for revoking user tokens
    private static let revokeTokenPath: String = "/login/token/revoke"
    static var revokeTokenUrl = URL(string: "\(baseUrl)\(revokeTokenPath)")!
    
    // The OAuth prompt specification
    private let prompt: String? = nil
    
    // The OAuth claims specification
    private let claims: String? = nil
    
    // The OAuth ACR claims specification
    private let acrValues: String? = nil
    
    // OAuth scopes being requested, for use when calling APIs after login
    static let scopes: [String]? = ["openid", "profile"]
    
    // Any additional parameters to be specified in the Authentication request
    static var additionalParameters: [String:String] = [:]
    
    // Configure additional parameters
    init() {
        configureAdditionalParameters()
    }
    
    func configureAdditionalParameters() {
        if prompt != nil {
            AuthConfig.additionalParameters["prompt"] = prompt
        }
        
        if claims != nil {
            AuthConfig.additionalParameters["claims"] = claims
        }
        
        if acrValues != nil {
            AuthConfig.additionalParameters["acr_values"] = acrValues
        }
    }
}
