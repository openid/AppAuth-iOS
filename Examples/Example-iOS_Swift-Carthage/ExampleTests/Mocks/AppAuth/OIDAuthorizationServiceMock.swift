//
//  OIDAuthorizationServiceMock.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All rights reserved.
//


import Foundation
import AppAuth
@testable import Example

// MARK: - OIDAuthorizationServiceMock -

class OIDAuthorizationServiceMock: AuthorizationServiceStaticBridge {
    
    // MARK: - discoverConfiguration
    
    static var discoverConfigurationForIssuerCompletionCallsCount = 0
    static var discoverConfigurationForIssuerCompletionCalled: Bool {
        discoverConfigurationForIssuerCompletionCallsCount > 0
    }
    static var discoverConfigurationForIssuerCompletionReceivedArguments: (issuerURL: URL, completion: OIDDiscoveryCallback)?
    static var discoverConfigurationForIssuerCompletionReceivedInvocations: [(issuerURL: URL, completion: OIDDiscoveryCallback)] = []
    static var discoverConfigurationForIssuerCompletionClosure: ((URL, @escaping OIDDiscoveryCallback) -> Void)?
    
    static func discoverConfiguration(forIssuer issuerURL: URL, completion: @escaping OIDDiscoveryCallback) {
        discoverConfigurationForIssuerCompletionCallsCount += 1
        discoverConfigurationForIssuerCompletionReceivedArguments = (issuerURL: issuerURL, completion: completion)
        discoverConfigurationForIssuerCompletionReceivedInvocations.append((issuerURL: issuerURL, completion: completion))
        discoverConfigurationForIssuerCompletionClosure?(issuerURL, completion)
    }
    
    // MARK: - perform
    
    static var performCallbackCallsCount = 0
    static var performCallbackCalled: Bool {
        performCallbackCallsCount > 0
    }
    static var performCallbackReceivedArguments: (request: OIDTokenRequest, callback: OIDTokenCallback)?
    static var performCallbackReceivedInvocations: [(request: OIDTokenRequest, callback: OIDTokenCallback)] = []
    static var performCallbackClosure: ((OIDTokenRequest, @escaping OIDTokenCallback) -> Void)?
    
    static func perform(_ request: OIDTokenRequest, callback: @escaping OIDTokenCallback) {
        performCallbackCallsCount += 1
        performCallbackReceivedArguments = (request: request, callback: callback)
        performCallbackReceivedInvocations.append((request: request, callback: callback))
        performCallbackClosure?(request, callback)
    }
    
    // MARK: - present
    
    static var presentPresentingCallbackCallsCount = 0
    static var presentPresentingCallbackCalled: Bool {
        presentPresentingCallbackCallsCount > 0
    }
    static var presentPresentingCallbackReceivedArguments: (request: OIDAuthorizationRequest, presentingViewController: UIViewController, callback: OIDAuthorizationCallback)?
    static var presentPresentingCallbackReceivedInvocations: [(request: OIDAuthorizationRequest, presentingViewController: UIViewController, callback: OIDAuthorizationCallback)] = []
    static var presentPresentingCallbackReturnValue: OIDExternalUserAgentSession!
    static var presentPresentingCallbackClosure: ((OIDAuthorizationRequest, UIViewController, @escaping OIDAuthorizationCallback) -> OIDExternalUserAgentSession)?
    
    static func present(_ request: OIDAuthorizationRequest, presenting presentingViewController: UIViewController, callback: @escaping OIDAuthorizationCallback) -> OIDExternalUserAgentSession {
        presentPresentingCallbackCallsCount += 1
        presentPresentingCallbackReceivedArguments = (request: request, presentingViewController: presentingViewController, callback: callback)
        presentPresentingCallbackReceivedInvocations.append((request: request, presentingViewController: presentingViewController, callback: callback))
        return presentPresentingCallbackClosure.map({ $0(request, presentingViewController, callback) }) ?? presentPresentingCallbackReturnValue
    }
    
    // MARK: - perform
    
    static var performOriginalAuthorizationResponseCallbackCallsCount = 0
    static var performOriginalAuthorizationResponseCallbackCalled: Bool {
        performOriginalAuthorizationResponseCallbackCallsCount > 0
    }
    static var performOriginalAuthorizationResponseCallbackReceivedArguments: (request: OIDTokenRequest, authorizationResponse: OIDAuthorizationResponse?, callback: OIDTokenCallback)?
    static var performOriginalAuthorizationResponseCallbackReceivedInvocations: [(request: OIDTokenRequest, authorizationResponse: OIDAuthorizationResponse?, callback: OIDTokenCallback)] = []
    static var performOriginalAuthorizationResponseCallbackClosure: ((OIDTokenRequest, OIDAuthorizationResponse?, @escaping OIDTokenCallback) -> Void)?
    
    static func perform(_ request: OIDTokenRequest, originalAuthorizationResponse authorizationResponse: OIDAuthorizationResponse?, callback: @escaping OIDTokenCallback) {
        performOriginalAuthorizationResponseCallbackCallsCount += 1
        performOriginalAuthorizationResponseCallbackReceivedArguments = (request: request, authorizationResponse: authorizationResponse, callback: callback)
        performOriginalAuthorizationResponseCallbackReceivedInvocations.append((request: request, authorizationResponse: authorizationResponse, callback: callback))
        performOriginalAuthorizationResponseCallbackClosure?(request, authorizationResponse, callback)
    }
    
    // MARK: - present
    
    static var presentExternalUserAgentCallbackCallsCount = 0
    static var presentExternalUserAgentCallbackCalled: Bool {
        presentExternalUserAgentCallbackCallsCount > 0
    }
    static var presentExternalUserAgentCallbackReceivedArguments: (request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent, callback: OIDEndSessionCallback)?
    static var presentExternalUserAgentCallbackReceivedInvocations: [(request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent, callback: OIDEndSessionCallback)] = []
    static var presentExternalUserAgentCallbackReturnValue: OIDExternalUserAgentSession!
    static var presentExternalUserAgentCallbackClosure: ((OIDEndSessionRequest, OIDExternalUserAgent, @escaping OIDEndSessionCallback) -> OIDExternalUserAgentSession)?
    
    static func present(_ request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent, callback: @escaping OIDEndSessionCallback) -> OIDExternalUserAgentSession {
        presentExternalUserAgentCallbackCallsCount += 1
        presentExternalUserAgentCallbackReceivedArguments = (request: request, externalUserAgent: externalUserAgent, callback: callback)
        presentExternalUserAgentCallbackReceivedInvocations.append((request: request, externalUserAgent: externalUserAgent, callback: callback))
        return presentExternalUserAgentCallbackClosure.map({ $0(request, externalUserAgent, callback) }) ?? presentExternalUserAgentCallbackReturnValue
    }
}
