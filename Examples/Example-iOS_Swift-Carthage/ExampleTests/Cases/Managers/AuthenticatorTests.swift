//
//  AuthenticatorTests.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation

import XCTest
import Foundation
import UIKit
import AppAuth
@testable import Example

/**
 Provides an example of a test class.
 */
import XCTest

@MainActor
class AuthenticatorTests: XCTestCase {
    
    var authenticator: Authenticator!
    
    override func setUp() async throws {
        let rootViewController = UIViewController()
        authenticator = Authenticator(rootViewController)
        
        try await authenticator.getDiscoveryConfig(AuthConfig.discoveryUrl)
    }
    
    override func tearDown() {
        authenticator.authStateManager.setAuthState(nil)
        authenticator.authStateManager.setBrowserState(.inactive)
        
        super.tearDown()
    }
    
    func testIsDiscoveryConfigLoaded() async throws {
        try await authenticator.getDiscoveryConfig(AuthConfig.discoveryUrl)
        XCTAssertNotNil(authenticator.discoveryConfig)
    }
    
    func testIsAuthStateIsInactive() {
        // Given: an unauthorized authorization state
        XCTAssertFalse(authenticator.isAuthStateActive)
    }
    
    func testIsAuthStateActive() {
        // Given: an authorized authorization state
        let authState = AppAuthMocks.setupMockAuthState()
        authenticator.authStateManager.setAuthState(authState)
        
        XCTAssertTrue(authenticator.isAuthStateActive)
    }
    
    func testIsAccessTokenRequestSuccessful() async throws {
        // Given: an access token request succeeds
        let authState = AppAuthMocks.setupMockAuthState()
        authenticator.authStateManager.setAuthState(authState)
        
        let accessToken = try await authenticator.getAccessToken()
        XCTAssertNotNil(accessToken)
    }
    
    func testBrowserSessionLoginWithAuthStateResponse() async throws {
        // Given: an active browser session resulting from an AuthState response
        
        let authState = AppAuthMocks.setupMockAuthState()
        try await authenticator.finishLoginWithAuthStateResponse(authState)
        
        XCTAssertTrue(authenticator.isBrowserSessionActive)
    }
    
    func testLoginWithNilAuthStateResponse() async throws {
        // Given: an inactive browser session resulting from no AuthState response
        
        try await authenticator.finishLoginWithAuthStateResponse(nil)
        
        XCTAssertFalse(self.authenticator.isBrowserSessionActive)
    }
    
    func testLoginWithAuthResponse() async throws {
        // Given: an active browser session resulting from an AuthState response
        let authResponse = AppAuthMocks.getAuthResponseMock()
        
        try await authenticator.finishLoginWithAuthResponse(authResponse)
        
        XCTAssertTrue(authenticator.isBrowserSessionActive)
    }
    
    func testLoginWithNilAuthResponse() async throws {
        // Given: an inactive browser session resulting from no AuthState response
        try await authenticator.finishLoginWithAuthResponse(nil)
        
        XCTAssertFalse(self.authenticator.isBrowserSessionActive)
    }
}
