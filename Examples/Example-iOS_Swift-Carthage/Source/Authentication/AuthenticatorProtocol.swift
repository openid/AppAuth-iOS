//
//  AuthenticatorProtocols.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All rights reserved.
//


import Foundation
import UIKit
import AppAuth

// MARK: AuthenticatorProtocol
protocol AuthenticatorProtocol: AnyObject {
    var rootViewController: UIViewController { get }
    var delegate: AuthenticatorDelegate? { get set }
    var authConfig: AuthConfigProtocol { get }
    var OIDAuthState: AuthStateStaticBridge.Type { get }
    var OIDAuthorizationService: AuthorizationServiceStaticBridge.Type { get }
    var authStateManager: AuthStateManagerProtocol { get }
    var webServiceManager: WebServiceManagerProtocol { get }
    var loginResponseHandler: LoginResponseHandlerProtocol { get }
    var logoutResponseHandler: LogoutResponseHandlerProtocol { get }
    var authStateResponseHandler: AuthStateResponseHandlerProtocol { get }
    var authRequestFactory: AuthRequestFactoryProtocol { get }
    
    var discoveryConfig: OIDServiceConfiguration? { get set }
    var discoveryConfigString: String? { get }
    var isAuthStateActive: Bool { get }
    var isBrowserSessionActive: Bool { get }
    var isAccessTokenRevoked: Bool { get }
    var isRefreshTokenRevoked: Bool { get }
    var accessToken: String? { get }
    var refreshToken: String? { get }
    var lastTokenResponse: OIDTokenResponse? { get }
    var isCodeExchangeRequired: Bool { get set }
    func loadDiscoveryConfig() async throws -> String
    func refreshTokens() async throws -> Void
    func revokeToken(tokenType: TokenType) async throws -> Void
    func performUserInfoRequest() async throws -> String
    func startBrowserLoginWithAutoCodeExchange() throws -> OIDExternalUserAgentSession
    func handleBrowserLoginWithAutoCodeExchangeResponse() async throws -> OIDAuthState
    func finishLoginWithAuthStateResponse(_ authState: OIDAuthState?) async throws -> Void
    func startBrowserLoginWithManualCodeExchange() throws -> OIDExternalUserAgentSession
    func handleBrowserLoginWithManualCodeExchangeResponse() async throws -> OIDAuthorizationResponse
    func finishLoginWithAuthResponse(_ authResponse: OIDAuthorizationResponse?) async throws -> Void
    func exchangeAuthorizationCode() async throws -> Void
    func startProfileManagementRedirect() throws -> OIDExternalUserAgentSession
    func handleProfileManagementResponse() async throws -> Void
    func startBrowserLogoutRedirect() throws -> OIDExternalUserAgentSession
    func handleBrowserLogoutResponse() async throws -> OIDEndSessionResponse
    func finishBrowserLogout(_ response: OIDEndSessionResponse?) async throws -> Void
    func performAppSessionLogout() async throws -> Void
}

// MARK: AuthenticatorDelegate
protocol AuthenticatorDelegate: AnyObject {
    func logMessage(_ message: String)
}
