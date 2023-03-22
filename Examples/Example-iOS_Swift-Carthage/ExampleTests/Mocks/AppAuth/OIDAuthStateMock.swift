//
//  OIDAuthStateMock.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All rights reserved.
//


import Foundation
import AppAuth
@testable import Example

// MARK: - OIDAuthStateMock -

class OIDAuthStateMock: AuthStateStaticBridge {
    
    // MARK: - authState
    
    static var authStateByPresentingPresentingCallbackCallsCount = 0
    static var authStateByPresentingPresentingCallbackCalled: Bool {
        authStateByPresentingPresentingCallbackCallsCount > 0
    }
    static var authStateByPresentingPresentingCallbackReceivedArguments: (authorizationRequest: OIDAuthorizationRequest, presentingViewController: UIViewController, callback: OIDAuthStateAuthorizationCallback)?
    static var authStateByPresentingPresentingCallbackReceivedInvocations: [(authorizationRequest: OIDAuthorizationRequest, presentingViewController: UIViewController, callback: OIDAuthStateAuthorizationCallback)] = []
    static var authStateByPresentingPresentingCallbackReturnValue: OIDExternalUserAgentSession!
    static var authStateByPresentingPresentingCallbackClosure: ((OIDAuthorizationRequest, UIViewController, @escaping OIDAuthStateAuthorizationCallback) -> OIDExternalUserAgentSession)?
    
    static func authState(byPresenting authorizationRequest: OIDAuthorizationRequest, presenting presentingViewController: UIViewController, callback: @escaping OIDAuthStateAuthorizationCallback) -> OIDExternalUserAgentSession {
        authStateByPresentingPresentingCallbackCallsCount += 1
        authStateByPresentingPresentingCallbackReceivedArguments = (authorizationRequest: authorizationRequest, presentingViewController: presentingViewController, callback: callback)
        authStateByPresentingPresentingCallbackReceivedInvocations.append((authorizationRequest: authorizationRequest, presentingViewController: presentingViewController, callback: callback))
        return authStateByPresentingPresentingCallbackClosure.map({ $0(authorizationRequest, presentingViewController, callback) }) ?? authStateByPresentingPresentingCallbackReturnValue
    }
}
