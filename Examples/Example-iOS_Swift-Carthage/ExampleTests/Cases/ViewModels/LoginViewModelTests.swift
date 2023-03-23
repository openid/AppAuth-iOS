//
//  LoginViewModelTests.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import XCTest
import Foundation
import UIKit
import AppAuth
@testable import Example

@MainActor
class LoginViewModelTests: XCTestCase {
    
    var sut: LoginViewModel!
    
    var authenticatorMock: AuthenticatorMock!
    var appAuthMocks: AppAuthMocks!
    var authConfigMock: AuthConfigMock!
    var viewCoordinatorDelegateMock: LoginViewModelCoordinatorDelegateMock!
    
    override func setUp() {
        super.setUp()
        
        authenticatorMock = AuthenticatorMock()
        sut = LoginViewModel(authenticatorMock)
        
        viewCoordinatorDelegateMock = LoginViewModelCoordinatorDelegateMock()
        
        sut.coordinatorDelegate = viewCoordinatorDelegateMock
        
        authConfigMock = AuthConfigMock()
        appAuthMocks = AppAuthMocks()
    }
    
    override func tearDown() {
        sut = nil
        viewCoordinatorDelegateMock = nil
        authenticatorMock = nil
        appAuthMocks = nil
        authConfigMock = nil
        AppDelegate.shared.currentAuthorizationFlow = nil
        
        super.tearDown()
    }
    
    // MARK: - Load discovery config test methods
    
    func testDiscoverConfigurationSucceeded() async throws {
        
        // Given: A discovery document does exist
        let discoveryConfig = appAuthMocks.loadMockServiceConfig(issuer: authConfigMock.discoveryUrl)
        authenticatorMock.loadDiscoveryConfigReturnValue = discoveryConfig.description
        
        do {
            let config = try await sut.discoverConfiguration()
            XCTAssertNotNil(config)
        } catch {
            XCTFail("Expected to succeed while awaiting, but failed.")
        }
        
        XCTAssertTrue(authenticatorMock.loadDiscoveryConfigCalled)
    }
    
    func testDiscoverConfigurationFailed() async throws {
        
        // Given: A discovery document does not exist
        authenticatorMock.loadDiscoveryConfigThrowableError = AuthError.noDiscoveryDoc
        
        do {
            let _ = try await sut.discoverConfiguration()
            XCTFail("Expected to throw while awaiting, but succeeded.")
        } catch {
            XCTAssertEqual(error as? AuthError, .noDiscoveryDoc)
        }
    }
    
    // MARK: - Test authentication selection
    
    func testAuthenticationTypeHandlerWhenAutoCodeExchangeIsSelected() async throws {
        
        // Given: Manual code exchange is not selected
        XCTAssertFalse(sut.isManualCodeExchange)
        
        // When: Auto code exchange authentication is called
        let sessionMock = OIDExternalUserAgentMock().getExternalUserAgentSession()
        authenticatorMock.startBrowserLoginWithAutoCodeExchangeReturnValue = sessionMock
        authenticatorMock.handleBrowserLoginWithAutoCodeExchangeResponseReturnValue = appAuthMocks.setupMockAuthState()
        
        try await sut.beginBrowserAuthentication()
        
        // Then: Auto code exchange authentication is called
        XCTAssertFalse(sut.isManualCodeExchange)
        XCTAssert(authenticatorMock.startBrowserLoginWithAutoCodeExchangeCalled)
        XCTAssert(authenticatorMock.handleBrowserLoginWithAutoCodeExchangeResponseCalled)
        XCTAssert(authenticatorMock.finishLoginWithAuthStateResponseCalled)
    }
    
    func testAuthenticationTypeHandlerWhenManualCodeExchangeIsSelected() async throws {
        
        // Given: Manual code exchange is not selected
        XCTAssertFalse(sut.isManualCodeExchange)
        
        // When: Manual code exchange is selected
        sut.setManualCodeExchange(true)
        
        let sessionMock = OIDExternalUserAgentMock().getExternalUserAgentSession()
        authenticatorMock.startBrowserLoginWithManualCodeExchangeReturnValue = sessionMock
        authenticatorMock.handleBrowserLoginWithManualCodeExchangeResponseReturnValue = appAuthMocks.getAuthResponseMock()
        
        try await sut.beginBrowserAuthentication()
        
        // Then: Manual code exchange authentication is called
        XCTAssertTrue(sut.isManualCodeExchange)
        XCTAssert(authenticatorMock.startBrowserLoginWithManualCodeExchangeCalled)
        XCTAssert(authenticatorMock.handleBrowserLoginWithManualCodeExchangeResponseCalled)
        XCTAssert(authenticatorMock.finishLoginWithAuthResponseCalled)
    }
}
