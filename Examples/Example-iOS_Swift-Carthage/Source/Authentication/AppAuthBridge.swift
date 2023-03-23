//
//  AppAuthProtocol.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All rights reserved.
//


import Foundation
import AppAuth

/*
 * A protocol bridge for static function calls inside the AppAuth framework.
 *
 * This allows the static AppAuth function calls to be injected for testing.
 *
 */

// MARK: AuthStateStaticLibBridge
protocol AuthStateStaticBridge {
    static func authState(byPresenting authorizationRequest: OIDAuthorizationRequest, presenting presentingViewController: UIViewController, callback: @escaping OIDAuthStateAuthorizationCallback) -> OIDExternalUserAgentSession
}
extension OIDAuthState: AuthStateStaticBridge { }

// MARK: AuthorizationServiceStaticLibBridge
protocol AuthorizationServiceStaticBridge {
    static func discoverConfiguration(forIssuer issuerURL: URL, completion: @escaping OIDDiscoveryCallback)
    static func perform(_ request: OIDTokenRequest, callback: @escaping OIDTokenCallback)
    static func present(_ request: OIDAuthorizationRequest, presenting presentingViewController: UIViewController, callback: @escaping OIDAuthorizationCallback) -> OIDExternalUserAgentSession
    static func perform(_ request: OIDTokenRequest, originalAuthorizationResponse authorizationResponse: OIDAuthorizationResponse?, callback: @escaping OIDTokenCallback)
    static func present(_ request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent, callback: @escaping OIDEndSessionCallback) -> OIDExternalUserAgentSession
}
extension OIDAuthorizationService: AuthorizationServiceStaticBridge { }
