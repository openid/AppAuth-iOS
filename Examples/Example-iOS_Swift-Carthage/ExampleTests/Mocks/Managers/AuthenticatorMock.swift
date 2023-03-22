//
//  AuthenticatorMock.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import AppAuth
@testable import Example

// MARK: - AuthenticatorMock -

class AuthenticatorMock: AuthenticatorProtocol {
    
    // MARK: - rootViewController
    
    var rootViewController: UIViewController {
        get { underlyingRootViewController }
        set(value) { underlyingRootViewController = value }
    }
    private var underlyingRootViewController: UIViewController!
    var delegate: AuthenticatorDelegate?
    
    // MARK: - authConfig
    
    var authConfig: AuthConfigProtocol {
        get { underlyingAuthConfig }
        set(value) { underlyingAuthConfig = value }
    }
    private var underlyingAuthConfig: AuthConfigProtocol!
    
    // MARK: - OIDAuthState
    
    var OIDAuthState: AuthStateStaticBridge.Type {
        get { underlyingOIDAuthState }
        set(value) { underlyingOIDAuthState = value }
    }
    private var underlyingOIDAuthState: AuthStateStaticBridge.Type!
    
    // MARK: - OIDAuthorizationService
    
    var OIDAuthorizationService: AuthorizationServiceStaticBridge.Type {
        get { underlyingOIDAuthorizationService }
        set(value) { underlyingOIDAuthorizationService = value }
    }
    private var underlyingOIDAuthorizationService: AuthorizationServiceStaticBridge.Type!
    
    // MARK: - authStateManager
    
    var authStateManager: AuthStateManagerProtocol {
        get { underlyingAuthStateManager }
        set(value) { underlyingAuthStateManager = value }
    }
    private var underlyingAuthStateManager: AuthStateManagerProtocol!
    
    // MARK: - webServiceManager
    
    var webServiceManager: WebServiceManagerProtocol {
        get { underlyingWebServiceManager }
        set(value) { underlyingWebServiceManager = value }
    }
    private var underlyingWebServiceManager: WebServiceManagerProtocol!
    
    // MARK: - loginResponseHandler
    
    var loginResponseHandler: LoginResponseHandlerProtocol {
        get { underlyingLoginResponseHandler }
        set(value) { underlyingLoginResponseHandler = value }
    }
    private var underlyingLoginResponseHandler: LoginResponseHandlerProtocol!
    
    // MARK: - logoutResponseHandler
    
    var logoutResponseHandler: LogoutResponseHandlerProtocol {
        get { underlyingLogoutResponseHandler }
        set(value) { underlyingLogoutResponseHandler = value }
    }
    private var underlyingLogoutResponseHandler: LogoutResponseHandlerProtocol!
    
    // MARK: - authStateResponseHandler
    
    var authStateResponseHandler: AuthStateResponseHandlerProtocol {
        get { underlyingAuthStateResponseHandler }
        set(value) { underlyingAuthStateResponseHandler = value }
    }
    private var underlyingAuthStateResponseHandler: AuthStateResponseHandlerProtocol!
    
    // MARK: - authRequestFactory
    
    var authRequestFactory: AuthRequestFactoryProtocol {
        get { underlyingAuthRequestFactory }
        set(value) { underlyingAuthRequestFactory = value }
    }
    private var underlyingAuthRequestFactory: AuthRequestFactoryProtocol!
    var discoveryConfig: OIDServiceConfiguration?
    var discoveryConfigString: String?
    
    
    // MARK: - isAuthStateActive
    
    var isAuthStateActive: Bool {
        get { underlyingIsAuthStateActive }
        set(value) { underlyingIsAuthStateActive = value }
    }
    private var underlyingIsAuthStateActive: Bool = false
    
    // MARK: - isBrowserSessionActive
    
    var isBrowserSessionActive: Bool {
        get { underlyingIsBrowserSessionActive }
        set(value) { underlyingIsBrowserSessionActive = value }
    }
    private var underlyingIsBrowserSessionActive: Bool = false
    
    // MARK: - isAccessTokenRevoked
    
    var isAccessTokenRevoked: Bool {
        get { underlyingIsAccessTokenRevoked }
        set(value) { underlyingIsAccessTokenRevoked = value }
    }
    private var underlyingIsAccessTokenRevoked: Bool = false
    
    // MARK: - isRefreshTokenRevoked
    
    var isRefreshTokenRevoked: Bool {
        get { underlyingIsRefreshTokenRevoked }
        set(value) { underlyingIsRefreshTokenRevoked = value }
    }
    private var underlyingIsRefreshTokenRevoked: Bool = false
    var accessToken: String?
    var refreshToken: String?
    var lastTokenResponse: OIDTokenResponse?
    
    // MARK: - isCodeExchangeRequired
    
    var isCodeExchangeRequired: Bool {
        get { underlyingIsCodeExchangeRequired }
        set(value) { underlyingIsCodeExchangeRequired = value }
    }
    private var underlyingIsCodeExchangeRequired: Bool = false
    
    // MARK: - loadDiscoveryConfig
    
    var loadDiscoveryConfigThrowableError: Error?
    var loadDiscoveryConfigCallsCount = 0
    var loadDiscoveryConfigCalled: Bool {
        loadDiscoveryConfigCallsCount > 0
    }
    var loadDiscoveryConfigReturnValue: String!
    var loadDiscoveryConfigClosure: (() throws -> String)?
    
    func loadDiscoveryConfig() throws -> String {
        if let error = loadDiscoveryConfigThrowableError {
            throw error
        }
        loadDiscoveryConfigCallsCount += 1
        return try loadDiscoveryConfigClosure.map({ try $0() }) ?? loadDiscoveryConfigReturnValue
    }
    
    // MARK: - refreshTokens
    
    var refreshTokensThrowableError: Error?
    var refreshTokensCallsCount = 0
    var refreshTokensCalled: Bool {
        refreshTokensCallsCount > 0
    }
    var refreshTokensClosure: (() throws -> Void)?
    
    func refreshTokens() throws {
        if let error = refreshTokensThrowableError {
            throw error
        }
        refreshTokensCallsCount += 1
        try refreshTokensClosure?()
    }
    
    // MARK: - revokeToken
    
    var revokeTokenTokenTypeThrowableError: Error?
    var revokeTokenTokenTypeCallsCount = 0
    var revokeTokenTokenTypeCalled: Bool {
        revokeTokenTokenTypeCallsCount > 0
    }
    var revokeTokenTokenTypeReceivedTokenType: TokenType?
    var revokeTokenTokenTypeReceivedInvocations: [TokenType] = []
    var revokeTokenTokenTypeClosure: ((TokenType) throws -> Void)?
    
    func revokeToken(tokenType: TokenType) throws {
        if let error = revokeTokenTokenTypeThrowableError {
            throw error
        }
        revokeTokenTokenTypeCallsCount += 1
        revokeTokenTokenTypeReceivedTokenType = tokenType
        revokeTokenTokenTypeReceivedInvocations.append(tokenType)
        try revokeTokenTokenTypeClosure?(tokenType)
    }
    
    // MARK: - performUserInfoRequest
    
    var performUserInfoRequestThrowableError: Error?
    var performUserInfoRequestCallsCount = 0
    var performUserInfoRequestCalled: Bool {
        performUserInfoRequestCallsCount > 0
    }
    var performUserInfoRequestReturnValue: String!
    var performUserInfoRequestClosure: (() throws -> String)?
    
    func performUserInfoRequest() throws -> String {
        if let error = performUserInfoRequestThrowableError {
            throw error
        }
        performUserInfoRequestCallsCount += 1
        return try performUserInfoRequestClosure.map({ try $0() }) ?? performUserInfoRequestReturnValue
    }
    
    // MARK: - startBrowserLoginWithAutoCodeExchange
    
    var startBrowserLoginWithAutoCodeExchangeThrowableError: Error?
    var startBrowserLoginWithAutoCodeExchangeCallsCount = 0
    var startBrowserLoginWithAutoCodeExchangeCalled: Bool {
        startBrowserLoginWithAutoCodeExchangeCallsCount > 0
    }
    var startBrowserLoginWithAutoCodeExchangeReturnValue: OIDExternalUserAgentSession!
    var startBrowserLoginWithAutoCodeExchangeClosure: (() throws -> OIDExternalUserAgentSession)?
    
    func startBrowserLoginWithAutoCodeExchange() throws -> OIDExternalUserAgentSession {
        if let error = startBrowserLoginWithAutoCodeExchangeThrowableError {
            throw error
        }
        startBrowserLoginWithAutoCodeExchangeCallsCount += 1
        return try startBrowserLoginWithAutoCodeExchangeClosure.map({ try $0() }) ?? startBrowserLoginWithAutoCodeExchangeReturnValue
    }
    
    // MARK: - handleBrowserLoginWithAutoCodeExchangeResponse
    
    var handleBrowserLoginWithAutoCodeExchangeResponseThrowableError: Error?
    var handleBrowserLoginWithAutoCodeExchangeResponseCallsCount = 0
    var handleBrowserLoginWithAutoCodeExchangeResponseCalled: Bool {
        handleBrowserLoginWithAutoCodeExchangeResponseCallsCount > 0
    }
    var handleBrowserLoginWithAutoCodeExchangeResponseReturnValue: OIDAuthState!
    var handleBrowserLoginWithAutoCodeExchangeResponseClosure: (() throws -> OIDAuthState)?
    
    func handleBrowserLoginWithAutoCodeExchangeResponse() throws -> OIDAuthState {
        if let error = handleBrowserLoginWithAutoCodeExchangeResponseThrowableError {
            throw error
        }
        handleBrowserLoginWithAutoCodeExchangeResponseCallsCount += 1
        return try handleBrowserLoginWithAutoCodeExchangeResponseClosure.map({ try $0() }) ?? handleBrowserLoginWithAutoCodeExchangeResponseReturnValue
    }
    
    // MARK: - finishLoginWithAuthStateResponse
    
    var finishLoginWithAuthStateResponseThrowableError: Error?
    var finishLoginWithAuthStateResponseCallsCount = 0
    var finishLoginWithAuthStateResponseCalled: Bool {
        finishLoginWithAuthStateResponseCallsCount > 0
    }
    var finishLoginWithAuthStateResponseReceivedAuthState: OIDAuthState?
    var finishLoginWithAuthStateResponseReceivedInvocations: [OIDAuthState?] = []
    var finishLoginWithAuthStateResponseClosure: ((OIDAuthState?) throws -> Void)?
    
    func finishLoginWithAuthStateResponse(_ authState: OIDAuthState?) throws {
        if let error = finishLoginWithAuthStateResponseThrowableError {
            throw error
        }
        finishLoginWithAuthStateResponseCallsCount += 1
        finishLoginWithAuthStateResponseReceivedAuthState = authState
        finishLoginWithAuthStateResponseReceivedInvocations.append(authState)
        try finishLoginWithAuthStateResponseClosure?(authState)
    }
    
    // MARK: - startBrowserLoginWithManualCodeExchange
    
    var startBrowserLoginWithManualCodeExchangeThrowableError: Error?
    var startBrowserLoginWithManualCodeExchangeCallsCount = 0
    var startBrowserLoginWithManualCodeExchangeCalled: Bool {
        startBrowserLoginWithManualCodeExchangeCallsCount > 0
    }
    var startBrowserLoginWithManualCodeExchangeReturnValue: OIDExternalUserAgentSession!
    var startBrowserLoginWithManualCodeExchangeClosure: (() throws -> OIDExternalUserAgentSession)?
    
    func startBrowserLoginWithManualCodeExchange() throws -> OIDExternalUserAgentSession {
        if let error = startBrowserLoginWithManualCodeExchangeThrowableError {
            throw error
        }
        startBrowserLoginWithManualCodeExchangeCallsCount += 1
        return try startBrowserLoginWithManualCodeExchangeClosure.map({ try $0() }) ?? startBrowserLoginWithManualCodeExchangeReturnValue
    }
    
    // MARK: - handleBrowserLoginWithManualCodeExchangeResponse
    
    var handleBrowserLoginWithManualCodeExchangeResponseThrowableError: Error?
    var handleBrowserLoginWithManualCodeExchangeResponseCallsCount = 0
    var handleBrowserLoginWithManualCodeExchangeResponseCalled: Bool {
        handleBrowserLoginWithManualCodeExchangeResponseCallsCount > 0
    }
    var handleBrowserLoginWithManualCodeExchangeResponseReturnValue: OIDAuthorizationResponse!
    var handleBrowserLoginWithManualCodeExchangeResponseClosure: (() throws -> OIDAuthorizationResponse)?
    
    func handleBrowserLoginWithManualCodeExchangeResponse() throws -> OIDAuthorizationResponse {
        if let error = handleBrowserLoginWithManualCodeExchangeResponseThrowableError {
            throw error
        }
        handleBrowserLoginWithManualCodeExchangeResponseCallsCount += 1
        return try handleBrowserLoginWithManualCodeExchangeResponseClosure.map({ try $0() }) ?? handleBrowserLoginWithManualCodeExchangeResponseReturnValue
    }
    
    // MARK: - finishLoginWithAuthResponse
    
    var finishLoginWithAuthResponseThrowableError: Error?
    var finishLoginWithAuthResponseCallsCount = 0
    var finishLoginWithAuthResponseCalled: Bool {
        finishLoginWithAuthResponseCallsCount > 0
    }
    var finishLoginWithAuthResponseReceivedAuthResponse: OIDAuthorizationResponse?
    var finishLoginWithAuthResponseReceivedInvocations: [OIDAuthorizationResponse?] = []
    var finishLoginWithAuthResponseClosure: ((OIDAuthorizationResponse?) throws -> Void)?
    
    func finishLoginWithAuthResponse(_ authResponse: OIDAuthorizationResponse?) throws {
        if let error = finishLoginWithAuthResponseThrowableError {
            throw error
        }
        finishLoginWithAuthResponseCallsCount += 1
        finishLoginWithAuthResponseReceivedAuthResponse = authResponse
        finishLoginWithAuthResponseReceivedInvocations.append(authResponse)
        try finishLoginWithAuthResponseClosure?(authResponse)
    }
    
    // MARK: - exchangeAuthorizationCode
    
    var exchangeAuthorizationCodeThrowableError: Error?
    var exchangeAuthorizationCodeCallsCount = 0
    var exchangeAuthorizationCodeCalled: Bool {
        exchangeAuthorizationCodeCallsCount > 0
    }
    var exchangeAuthorizationCodeClosure: (() throws -> Void)?
    
    func exchangeAuthorizationCode() throws {
        if let error = exchangeAuthorizationCodeThrowableError {
            throw error
        }
        exchangeAuthorizationCodeCallsCount += 1
        try exchangeAuthorizationCodeClosure?()
    }
    
    // MARK: - startProfileManagementRedirect
    
    var startProfileManagementRedirectThrowableError: Error?
    var startProfileManagementRedirectCallsCount = 0
    var startProfileManagementRedirectCalled: Bool {
        startProfileManagementRedirectCallsCount > 0
    }
    var startProfileManagementRedirectReturnValue: OIDExternalUserAgentSession!
    var startProfileManagementRedirectClosure: (() throws -> OIDExternalUserAgentSession)?
    
    func startProfileManagementRedirect() throws -> OIDExternalUserAgentSession {
        if let error = startProfileManagementRedirectThrowableError {
            throw error
        }
        startProfileManagementRedirectCallsCount += 1
        return try startProfileManagementRedirectClosure.map({ try $0() }) ?? startProfileManagementRedirectReturnValue
    }
    
    // MARK: - handleProfileManagementResponse
    
    var handleProfileManagementResponseThrowableError: Error?
    var handleProfileManagementResponseCallsCount = 0
    var handleProfileManagementResponseCalled: Bool {
        handleProfileManagementResponseCallsCount > 0
    }
    var handleProfileManagementResponseClosure: (() throws -> Void)?
    
    func handleProfileManagementResponse() throws {
        if let error = handleProfileManagementResponseThrowableError {
            throw error
        }
        handleProfileManagementResponseCallsCount += 1
        try handleProfileManagementResponseClosure?()
    }
    
    // MARK: - startBrowserLogoutRedirect
    
    var startBrowserLogoutRedirectThrowableError: Error?
    var startBrowserLogoutRedirectCallsCount = 0
    var startBrowserLogoutRedirectCalled: Bool {
        startBrowserLogoutRedirectCallsCount > 0
    }
    var startBrowserLogoutRedirectReturnValue: OIDExternalUserAgentSession!
    var startBrowserLogoutRedirectClosure: (() throws -> OIDExternalUserAgentSession)?
    
    func startBrowserLogoutRedirect() throws -> OIDExternalUserAgentSession {
        if let error = startBrowserLogoutRedirectThrowableError {
            throw error
        }
        startBrowserLogoutRedirectCallsCount += 1
        return try startBrowserLogoutRedirectClosure.map({ try $0() }) ?? startBrowserLogoutRedirectReturnValue
    }
    
    // MARK: - handleBrowserLogoutResponse
    
    var handleBrowserLogoutResponseThrowableError: Error?
    var handleBrowserLogoutResponseCallsCount = 0
    var handleBrowserLogoutResponseCalled: Bool {
        handleBrowserLogoutResponseCallsCount > 0
    }
    var handleBrowserLogoutResponseReturnValue: OIDEndSessionResponse!
    var handleBrowserLogoutResponseClosure: (() throws -> OIDEndSessionResponse)?
    
    func handleBrowserLogoutResponse() throws -> OIDEndSessionResponse {
        if let error = handleBrowserLogoutResponseThrowableError {
            throw error
        }
        handleBrowserLogoutResponseCallsCount += 1
        return try handleBrowserLogoutResponseClosure.map({ try $0() }) ?? handleBrowserLogoutResponseReturnValue
    }
    
    // MARK: - finishBrowserLogout
    
    var finishBrowserLogoutThrowableError: Error?
    var finishBrowserLogoutCallsCount = 0
    var finishBrowserLogoutCalled: Bool {
        finishBrowserLogoutCallsCount > 0
    }
    var finishBrowserLogoutReceivedResponse: OIDEndSessionResponse?
    var finishBrowserLogoutReceivedInvocations: [OIDEndSessionResponse?] = []
    var finishBrowserLogoutClosure: ((OIDEndSessionResponse?) throws -> Void)?
    
    func finishBrowserLogout(_ response: OIDEndSessionResponse?) throws {
        if let error = finishBrowserLogoutThrowableError {
            throw error
        }
        finishBrowserLogoutCallsCount += 1
        finishBrowserLogoutReceivedResponse = response
        finishBrowserLogoutReceivedInvocations.append(response)
        try finishBrowserLogoutClosure?(response)
    }
    
    // MARK: - performAppSessionLogout
    
    var performAppSessionLogoutThrowableError: Error?
    var performAppSessionLogoutCallsCount = 0
    var performAppSessionLogoutCalled: Bool {
        performAppSessionLogoutCallsCount > 0
    }
    var performAppSessionLogoutClosure: (() throws -> Void)?
    
    func performAppSessionLogout() throws {
        if let error = performAppSessionLogoutThrowableError {
            throw error
        }
        performAppSessionLogoutCallsCount += 1
        try performAppSessionLogoutClosure?()
    }
}
