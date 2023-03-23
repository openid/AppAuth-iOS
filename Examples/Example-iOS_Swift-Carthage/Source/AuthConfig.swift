//
//  AuthConfig.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation

// MARK: AuthConfigProtocol
protocol AuthConfigProtocol {
    var authStateStorageKey: String { get }
    var browserStateStorageKey: String { get }
    var redirectUriScheme: String { get }
    var redirectUrl: URL! { get }
    var clientId: String { get }
    var discoveryUrl: URL! { get }
    var profileManagementUrl: URL! { get }
    var customLogoutUrl: URL! { get }
    var revokeTokenUrl: URL! { get }
    var prompt: String? { get }
    var claims: String? { get }
    var acrValues: String? { get }
    var scopes: [String]? { get }
    var additionalParameters: [String:String] { get set }
}

class AuthConfig: AuthConfigProtocol {
    
    // User defaults storage keys
    let authStateStorageKey = "authState"
    let browserStateStorageKey = "browserState"
    
    // The redirect URI for the mobile app.
    // This needs to match the plist redirect scheme
    let redirectUriScheme: String = "net.openid.appauthdemo"
    let redirectUriHost: String = "oauth2redirect"
    
    // The OAuth client id
    let clientId: String = "cec9a504-a0ab-4b92-879b-711482a3f69b"
    
    // The base url for OAuth services
    private let baseUrl: String = "https://api.multi.dev.or.janrain.com/00000000-0000-0000-0000-000000000000"
    
    // The OIDC issuer from which the configuration will be discovered
    private let discoveryPath: String = "/login"
    
    // The path for accessing profile management
    private let profileManagementPath: String = "/auth-ui/profile"
    
    // The custom browser session logout path
    private let customLogoutPath: String = "/auth-ui/logout"
    
    // The path for revoking user tokens
    private let revokeTokenPath: String = "/login/token/revoke"
    
    // The OAuth prompt specification
    let prompt: String? = nil
    
    // The OAuth claims specification
    let claims: String? = nil
    
    // The OAuth ACR claims specification
    let acrValues: String? = nil
    
    // OAuth scopes being requested, for use when calling APIs after login
    let scopes: [String]? = ["openid", "profile"]
    
    // Any additional parameters to be specified in the Authentication request
    var additionalParameters: [String:String] = [:]
    
    func configureAdditionalParameters() {
        if prompt != nil {
            additionalParameters["prompt"] = prompt
        }
        
        if claims != nil {
            additionalParameters["claims"] = claims
        }
        
        if acrValues != nil {
            additionalParameters["acr_values"] = acrValues
        }
    }
    
    // The URLs are initialized from the paths
    var discoveryUrl: URL!
    var redirectUrl: URL!
    var profileManagementUrl: URL!
    var customLogoutUrl: URL!
    var revokeTokenUrl: URL!
    
    init() {
        discoveryUrl = URL(string: "\(baseUrl)\(discoveryPath)")!
        redirectUrl = URL(string: redirectUriScheme + "://" + redirectUriHost)!
        profileManagementUrl = URL(string: "\(baseUrl)\(profileManagementPath)")!
        customLogoutUrl = URL(string: "\(baseUrl)\(customLogoutPath)")!
        revokeTokenUrl = URL(string: "\(baseUrl)\(revokeTokenPath)")!
        configureAdditionalParameters()
    }
}
