//
//  AuthStateResponseHandlerMock.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All rights reserved.
//


import Foundation
import AppAuth
@testable import Example


// MARK: - AuthStateResponseHandlerMock -

final class AuthStateResponseHandlerMock: AuthStateResponseHandlerProtocol {
    var storedContinuation: CheckedContinuation<OIDAuthState, Error>?
    
    // MARK: - waitForCallback
    
    var waitForCallbackThrowableError: Error?
    var waitForCallbackCallsCount = 0
    var waitForCallbackCalled: Bool {
        waitForCallbackCallsCount > 0
    }
    var waitForCallbackReturnValue: OIDAuthState!
    var waitForCallbackClosure: (() throws -> OIDAuthState)?
    
    func waitForCallback() throws -> OIDAuthState {
        if let error = waitForCallbackThrowableError {
            throw error
        }
        waitForCallbackCallsCount += 1
        return try waitForCallbackClosure.map({ try $0() }) ?? waitForCallbackReturnValue
    }
    
    // MARK: - callback
    
    var callbackResponseErrorCallsCount = 0
    var callbackResponseErrorCalled: Bool {
        callbackResponseErrorCallsCount > 0
    }
    var callbackResponseErrorReceivedArguments: (response: OIDAuthState?, error: Error?)?
    var callbackResponseErrorReceivedInvocations: [(response: OIDAuthState?, error: Error?)] = []
    var callbackResponseErrorClosure: ((OIDAuthState?, Error?) -> Void)?
    
    func callback(response: OIDAuthState?, error: Error?) {
        callbackResponseErrorCallsCount += 1
        callbackResponseErrorReceivedArguments = (response: response, error: error)
        callbackResponseErrorReceivedInvocations.append((response: response, error: error))
        callbackResponseErrorClosure?(response, error)
    }
}
