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

@MainActor
class AuthenticatorTests: XCTestCase {
    
    var sut: Authenticator!
    
    var authConfigMock: AuthConfigMock!
    var appAuthMocks: AppAuthMocks!
    var authStateManagerMock: AuthStateManagerMock!
    var webServiceManagerMock: WebServiceManagerMock!
    var loginResponseHandlerMock: LoginResponseHandlerProtocol!
    var logoutResponseHandlerMock: LogoutResponseHandlerProtocol!
    var authStateResponseHandlerMock: AuthStateResponseHandlerProtocol!
    
    override func setUp() {
        super.setUp()
        
        authConfigMock = AuthConfigMock()
        appAuthMocks = AppAuthMocks()
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        let urlSession = URLSession.init(configuration: configuration)
        webServiceManagerMock = WebServiceManagerMock(urlSession)
        authStateManagerMock = AuthStateManagerMock()
        
        loginResponseHandlerMock = LoginResponseHandlerMock()
        logoutResponseHandlerMock = LogoutResponseHandlerMock()
        authStateResponseHandlerMock = AuthStateResponseHandlerMock()
        
        sut = Authenticator(authConfigMock,
                            rootViewController: SpyNavigationController(),
                            authStateManager: authStateManagerMock,
                            webServiceManager: webServiceManagerMock,
                            loginResponseHandler: loginResponseHandlerMock,
                            logoutResponseHandler: logoutResponseHandlerMock,
                            authStateResponseHandler: authStateResponseHandlerMock,
                            OIDAuthState: OIDAuthStateMock.self, OIDAuthorizationService: OIDAuthorizationServiceMock.self)
    }
    
    override func tearDown() {
        sut = nil
        authStateManagerMock = nil
        appAuthMocks = nil
        authConfigMock = nil
        webServiceManagerMock = nil
        loginResponseHandlerMock = nil
        logoutResponseHandlerMock = nil
        authStateResponseHandlerMock = nil
        
        super.tearDown()
    }
    
    func testDiscoveryConfigLoaded() async throws {
        
        // Given: A discovery doc is returned
        let discoveryConfig = appAuthMocks.loadMockServiceConfig(issuer: authConfigMock.discoveryUrl)
        
        OIDAuthorizationServiceMock.discoverConfigurationForIssuerCompletionClosure = { request, callback in
            callback(discoveryConfig, nil)
        }
        
        do {
            let discoveredConfig = try await sut.loadDiscoveryConfig()
            
            XCTAssertNotNil(discoveredConfig)
        } catch {
            XCTFail("Expected to succeed while awaiting, but failed.")
        }
    }
    
    func testAuthErrorIsReturnedWhenDisoveryConfigLoadFails() async throws {
        
        // Given: No discovery config exists
        XCTAssertNil(sut.discoveryConfig)
        
        // When: The discovery doc fails to load
        OIDAuthorizationServiceMock.discoverConfigurationForIssuerCompletionClosure = { request, callback in
            let error = OIDErrorUtilities.error(with: .networkError, underlyingError: nil, description: nil)
            callback(nil, error)
        }
        
        // Then: An error is thrown
        do {
            let _ = try await sut.loadDiscoveryConfig()
            XCTFail("Expected to fai while awaiting, but failed.")
            
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testRefreshTokenRequestSucceeds() async throws {
        // Given: A token refresh request exists in the stored auth state
        let authStateMock = appAuthMocks.setupMockAuthState()
        authStateManagerMock.tokenRefreshRequest = authStateMock.tokenRefreshRequest()
        OIDAuthorizationServiceMock.performCallbackClosure = { request, callback in
            callback(authStateMock.lastTokenResponse, nil)
        }
        try await sut.refreshTokens()
        XCTAssertTrue(authStateManagerMock.updateWithTokenResponseErrorCalled)
    }
    
    func testBrowserSessionLoginWithAuthStateResponse() async throws {
        // Given: an active browser session resulting from an AuthState response
        
        let authState = appAuthMocks.setupMockAuthState()
        try await sut.finishLoginWithAuthStateResponse(authState)
        
        XCTAssertTrue(authStateManagerMock.setAuthStateCalled)
        XCTAssertTrue(authStateManagerMock.setBrowserStateCalled)
        XCTAssertFalse(sut.isCodeExchangeRequired)
    }
    
    func testLoginWithNilAuthStateResponse() async throws {
        // Given: an inactive browser session resulting from no AuthState response
        try await sut.finishLoginWithAuthStateResponse(nil)
        
        XCTAssertFalse(sut.isBrowserSessionActive)
    }
    
    func testLoginWithAuthResponse() async throws {
        // Given: an active browser session resulting from an AuthState response
        let authResponse = appAuthMocks.getAuthResponseMock()
        
        try await sut.finishLoginWithAuthResponse(authResponse)
        
        XCTAssertTrue(sut.isBrowserSessionActive)
    }
    
    func testLoginWithNilAuthResponse() async throws {
        // Given: an inactive browser session resulting from no AuthState response
        try await sut.finishLoginWithAuthResponse(nil)
        
        XCTAssertFalse(sut.isBrowserSessionActive)
    }
    
    func testUserInfoRequestFailsWithUnauthorizedAccessToken() async throws {
        // Given: a user info request with an unauthorized access token fails
        let authState = appAuthMocks.setupMockAuthState()
        authStateManagerMock.setAuthState(authState)
        
        var responseError: AuthError?
        
        do {
            let _ = try await sut.performUserInfoRequest()
        } catch let error as AuthError {
            responseError = error
        }
        
        let authError = try XCTUnwrap(responseError)
        print(authError.localizedDescription)
        XCTAssertNotNil(authError)
    }
}
