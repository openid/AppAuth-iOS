//
//  AuthRequestFactoryTests.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import XCTest
import Foundation
import UIKit
import AppAuth
@testable import Example

class AuthRequestFactoryTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var sut: AuthRequestFactory!
    
    var authConfigMock: AuthConfigMock!
    var appAuthMocks: AppAuthMocks!
    
    override func setUp() {
        authConfigMock = AuthConfigMock()
        sut = AuthRequestFactory(authConfigMock)
        appAuthMocks = AppAuthMocks()
    }
    
    override func tearDown() {
        sut = nil
        authConfigMock = nil
        appAuthMocks = nil
        
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    func testBrowserLoginRequest() {
        let discoveryConfig = appAuthMocks.loadMockServiceConfig(issuer: authConfigMock.discoveryUrl)
        let request = sut.browserLoginRequest(discoveryConfig)
        
        XCTAssertEqual(request.configuration, discoveryConfig)
        XCTAssertEqual(request.clientID, authConfigMock.clientId)
        XCTAssertEqual(request.redirectURL, authConfigMock.redirectUrl)
        XCTAssertEqual(request.responseType, OIDResponseTypeCode)
        XCTAssertEqual(request.additionalParameters, authConfigMock.additionalParameters)
    }
    
    func testProfileManagementRequest() {
        let discoveryConfig = appAuthMocks.loadMockServiceConfig(issuer: authConfigMock.discoveryUrl)
        let request = sut.profileManagementRequest(discoveryConfig)
        
        XCTAssertEqual(request.configuration.authorizationEndpoint, authConfigMock.profileManagementUrl)
        XCTAssertEqual(request.clientID, authConfigMock.clientId)
        XCTAssertEqual(request.redirectURL, authConfigMock.redirectUrl)
        XCTAssertEqual(request.responseType, OIDResponseTypeCode)
        XCTAssertEqual(request.additionalParameters, authConfigMock.additionalParameters)
    }
    
    func testBrowserLogoutRequest() {
        let discoveryConfig = appAuthMocks.loadMockServiceConfig(issuer: authConfigMock.discoveryUrl)
        let request = sut.browserLogoutRequest(discoveryConfig)
        
        let expectedConfig = OIDServiceConfiguration(
            authorizationEndpoint: discoveryConfig.authorizationEndpoint,
            tokenEndpoint: discoveryConfig.tokenEndpoint,
            issuer: discoveryConfig.issuer,
            registrationEndpoint: discoveryConfig.registrationEndpoint,
            endSessionEndpoint: authConfigMock.customLogoutUrl
        )
        
        XCTAssertEqual(request.configuration.authorizationEndpoint, expectedConfig.authorizationEndpoint)
        XCTAssertEqual(request.configuration.endSessionEndpoint, authConfigMock.customLogoutUrl)
        XCTAssertEqual(request.idTokenHint, "")
        XCTAssertEqual(request.postLogoutRedirectURL, authConfigMock.redirectUrl)
        XCTAssertEqual(request.additionalParameters?["client_id"] as? String, authConfigMock.clientId)
    }
    
    func testRevokeTokenRequest() {
        let tokenToRevoke = appAuthMocks.mockAccessToken
        guard let request = sut.revokeTokenRequest(tokenToRevoke) else {
            XCTFail("Failed to create revoke token request.")
            return
        }
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, authConfigMock.revokeTokenUrl)
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded")
        XCTAssertEqual(String(data: try XCTUnwrap(request.httpBody), encoding: .utf8), "token=\(tokenToRevoke)&client_id=\(authConfigMock.clientId)")
    }
    
    func testUserInfoRequest() {
        let discoveryConfig = appAuthMocks.loadMockServiceConfig(issuer: authConfigMock.discoveryUrl)
        let request = sut.userInfoRequest(discoveryConfig, accessToken: appAuthMocks.mockAccessToken)
        
        XCTAssertEqual(request?.url, discoveryConfig.discoveryDocument?.userinfoEndpoint)
        XCTAssertEqual(request?.allHTTPHeaderFields?["Authorization"], "Bearer \(appAuthMocks.mockAccessToken)")
    }
}
