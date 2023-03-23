//
//  AuthStateManager.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import XCTest
import Foundation
import UIKit
import AppAuth
@testable import Example

class AuthStateManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    var sut: AuthStateManager!
    
    var authConfigMock: AuthConfigMock!
    var appAuthMocks: AppAuthMocks!
    var userDefaults: UserDefaults!
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        
        authConfigMock = AuthConfigMock()
        appAuthMocks = AppAuthMocks()
        
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        sut = AuthStateManager(authConfigMock, userDefaults: userDefaults)
    }
    
    override func tearDown() {
        sut = nil
        authConfigMock = nil
        appAuthMocks = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testLoadAuthExistingState() throws {
        
        // Given: An AuthState does not exist
        XCTAssertNil(sut.authState)
        
        // When: An authorized AuthState is set and loaded
        sut = AppAuthMocks().setupMockAuthStateManager(true)
        sut.loadAuthState()
        
        // Then: The current AuthState should exist and be authorized
        XCTAssertNotNil(sut.authState)
        XCTAssertTrue(try XCTUnwrap(sut.authState?.isAuthorized))
    }
    
    func testSetAuthStateWhenSameState() {
        
        // Given: An AuthState is set
        let authState = appAuthMocks.setupMockAuthState()
        sut.setAuthState(authState)
        
        let originalAuthState = sut.authState
        
        // When: The same AuthState is set
        sut.setAuthState(authState)
        
        // Then: The current AuthState equals the original AuthState
        XCTAssertTrue(sut.authState == originalAuthState)
    }
    
    func testSetAuthStateWhenDifferentState() {
        
        // Given: An AuthState is set
        let originalAuthState = appAuthMocks.setupMockAuthState()
        sut.setAuthState(originalAuthState)
        
        // When: A different AuthState is set
        let newAuthState = appAuthMocks.setupMockAuthState(issuer: nil, clientId: nil)
        sut.setAuthState(newAuthState)
        
        // Then: The current AuthState does not equal the original
        XCTAssertFalse(originalAuthState == newAuthState)
        XCTAssertTrue(sut.authState == newAuthState)
    }
    
    func testUpdateWithValidTokenResponse() {
        
        // Given: Tokens are not set
        let mockAuthState = AppAuthMocks().setupMockAuthState(skipTokenResponse: true)
        sut.setAuthState(mockAuthState)
        XCTAssertNil(sut.accessToken)
        XCTAssertEqual(sut.accessTokenState, .inactive)
        XCTAssertNil(sut.refreshToken)
        XCTAssertEqual(sut.refreshTokenState, .inactive)
        
        // When: Token data is updated
        let tokenResponse = appAuthMocks.getTokenResponse()
        sut.updateWithTokenResponse(tokenResponse, error: nil)
        
        // Then: Token values are updated
        XCTAssertNotNil(sut.accessToken)
        XCTAssertEqual(sut.accessTokenState, .active)
        XCTAssertNotNil(sut.refreshToken)
        XCTAssertEqual(sut.refreshTokenState, .active)
    }
    
    func testSetAndLoadActiveBrowserState() {
        
        // Given: An inactive browser state
        XCTAssertEqual(sut.browserState, .inactive)
        
        // When: The browser state is set to active
        sut.setBrowserState(.active)
        
        // Then: The current browser state should be active
        XCTAssertEqual(sut.browserState, .active)
    }
    
    func testSetAndLoadInactiveBrowserState() {
        
        // Given: An active browser state
        sut.setBrowserState(.active)
        XCTAssertEqual(sut.browserState, .active)
        
        // When: Browser state is set to inactive
        sut.setBrowserState(.inactive)
        
        sut.loadBrowserState()
        
        // Then: Inactive browser state is loaded
        XCTAssertEqual(sut.browserState, .inactive)
    }
    
    func testSetBrowserStateWhenDifferentState() {
        
        // Given: An active browser state is set
        sut.setBrowserState(.active)
        XCTAssertEqual(sut.browserState, .active)
        
        // When: The browser state is set to inactive
        sut.setBrowserState(.inactive)
        
        // Then: The current browser state is inactive
        XCTAssertEqual(sut.browserState, .inactive)
    }
}
