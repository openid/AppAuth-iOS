//
//  AuthStateManager.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import XCTest
import Foundation
import UIKit
@testable import AppAuth
@testable import Example

class AuthStateManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    var authStateManager: AuthStateManager!
    var mockAuthState: OIDAuthState!
    var fakeUserDefaults: FakeUserDefaults!
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        authStateManager = AppAuthMocks.setupMockAuthStateManager(issuer: AuthConfig.discoveryUrl, clientId: AuthConfig.clientId)
        mockAuthState = AppAuthMocks.setupMockAuthState()
        fakeUserDefaults = FakeUserDefaults()
    }
    
    override func tearDown() {
        authStateManager.setAuthState(nil)
        authStateManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testLoadAuthState() {
        fakeUserDefaults.set(mockAuthState, forKey: AuthConfig.authStateStorageKey)
        authStateManager.loadAuthState()
        
        XCTAssertEqual(authStateManager.authState?.isAuthorized, true)
    }
    
    func testSetAuthState() {
        authStateManager.setAuthState(mockAuthState)
        
        XCTAssertEqual(authStateManager.authState?.isAuthorized, mockAuthState.isAuthorized)
    }
    
    func testSetAuthStateWhenSameState() {
        authStateManager.setAuthState(mockAuthState)
        let originalAuthState = authStateManager.authState
        
        authStateManager.setAuthState(mockAuthState)
        
        XCTAssertTrue(authStateManager.authState == originalAuthState)
    }
    
    func testSetAuthStateWhenDifferentState() {
        
        authStateManager.setAuthState(mockAuthState)
        let originalAuthState = authStateManager.authState
        
        let nilAuthState: OIDAuthState? = nil
        authStateManager.setAuthState(nilAuthState)
        
        XCTAssertFalse(authStateManager.authState == originalAuthState)
        XCTAssertEqual(authStateManager.authState, nil)
    }
    
    func testUpdateWithTokenResponse() {
        authStateManager.setAuthState(mockAuthState)
        
        let mockTokenResponse = AppAuthMocks.getTokenResponseMock()
        authStateManager.updateWithTokenResponse(mockTokenResponse, error: nil)
        
        XCTAssertEqual(authStateManager.lastTokenResponse?.accessToken, mockTokenResponse?.accessToken)
    }
    
    func testLoadBrowserState() {
        fakeUserDefaults.set(true, forKey: AuthConfig.browserStateStorageKey)
        authStateManager.loadBrowserState()
        
        XCTAssertEqual(authStateManager.browserState, .active)
    }
    
    func testSetBrowserState() {
        authStateManager.setBrowserState(.active)
        
        XCTAssertEqual(authStateManager.browserState, .active)
    }
    
    func testSetBrowserStateWhenSameState() {
        authStateManager.setBrowserState(.inactive)
        let originalBrowserState = authStateManager.browserState
        
        authStateManager.setBrowserState(.inactive)
        
        XCTAssertTrue(authStateManager.browserState == originalBrowserState)
    }
    
    func testSetBrowserStateWhenDifferentState() {
        authStateManager.setBrowserState(.inactive)
        let originalBrowserState = authStateManager.browserState
        
        authStateManager.setBrowserState(.active)
        
        XCTAssertFalse(authStateManager.browserState == originalBrowserState)
        XCTAssertEqual(authStateManager.browserState, .active)
    }
}
