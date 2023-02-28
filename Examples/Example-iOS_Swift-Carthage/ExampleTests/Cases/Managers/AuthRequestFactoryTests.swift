//
//  AuthRequestFactoryTests.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import XCTest
import Foundation
import UIKit
@testable import AppAuth
@testable import Example

class AuthRequestFactoryTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var discoveryConfig: OIDServiceConfiguration!
    var factory: AuthRequestFactory!
    var accessToken: String!
    var tokenToRevoke: String!
    
    override func setUp() {
        discoveryConfig = AppAuthMocks.getConfigurationMock()
        factory = AuthRequestFactory(discoveryConfig)
        accessToken = AppAuthMocks.mockAccessToken
        tokenToRevoke = AppAuthMocks.mockRefreshToken
    }
    
    override func tearDown() {
        discoveryConfig = nil
        factory = nil
        accessToken = nil
        tokenToRevoke = nil
    }
    
    // MARK: - Test Methods
    
    func testBrowserLoginRequest() {
        let request = factory.browserLoginRequest()
        
        XCTAssertEqual(request.configuration, discoveryConfig)
        XCTAssertEqual(request.clientID, AuthConfig.clientId)
        XCTAssertEqual(request.redirectURL, AuthConfig.redirectUrl)
        XCTAssertEqual(request.responseType, OIDResponseTypeCode)
        XCTAssertEqual(request.additionalParameters, AuthConfig.additionalParameters)
    }
    
    func testProfileManagementRequest() {
        let request = factory.profileManagementRequest()

        XCTAssertEqual(request.configuration.authorizationEndpoint, AuthConfig.profileManagementUrl)
        XCTAssertEqual(request.clientID, AuthConfig.clientId)
        XCTAssertEqual(request.redirectURL, AuthConfig.redirectUrl)
        XCTAssertEqual(request.responseType, OIDResponseTypeCode)
        XCTAssertEqual(request.additionalParameters, AuthConfig.additionalParameters)
    }
    
    func testBrowserLogoutRequest() {
        let request = factory.browserLogoutRequest()
        
        let expectedConfig = OIDServiceConfiguration(
            authorizationEndpoint: discoveryConfig.authorizationEndpoint,
            tokenEndpoint: discoveryConfig.tokenEndpoint,
            issuer: discoveryConfig.issuer,
            registrationEndpoint: discoveryConfig.registrationEndpoint,
            endSessionEndpoint: AuthConfig.customLogoutUrl
        )
        
        XCTAssertEqual(request.configuration.authorizationEndpoint, expectedConfig.authorizationEndpoint)
        XCTAssertEqual(request.configuration.endSessionEndpoint, AuthConfig.customLogoutUrl)
        XCTAssertEqual(request.idTokenHint, "")
        XCTAssertEqual(request.postLogoutRedirectURL, AuthConfig.redirectUrl)
        XCTAssertEqual(request.additionalParameters?["client_id"] as? String, AuthConfig.clientId)
    }
    
    func testRevokeTokenRequest() {
        guard let request = factory.revokeTokenRequest(tokenToRevoke) else {
            XCTFail("Failed to create revoke token request.")
            return
        }
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, AuthConfig.revokeTokenUrl)
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded")
        XCTAssertEqual(String(data: request.httpBody!, encoding: .utf8), "token=\(tokenToRevoke!)&client_id=\(AuthConfig.clientId)")
    }
    
    func testUserInfoRequest() {
        let request = factory.userInfoRequest(accessToken)
        
        XCTAssertEqual(request?.url, discoveryConfig.discoveryDocument?.userinfoEndpoint)
        XCTAssertEqual(request?.allHTTPHeaderFields?["Authorization"], "Bearer \(accessToken!)")
    }
}
