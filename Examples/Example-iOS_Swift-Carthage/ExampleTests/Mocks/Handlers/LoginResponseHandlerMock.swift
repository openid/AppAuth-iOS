//
//  LoginResponseHandlerMock.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All rights reserved.
//


import Foundation
import AppAuth
@testable import Example

// MARK: - LoginResponseHandlerMock -

class LoginResponseHandlerMock: LoginResponseHandlerProtocol {
    var storedContinuation: CheckedContinuation<OIDAuthorizationResponse, Error>?
    
    // MARK: - waitForCallback
    
    var waitForCallbackThrowableError: Error?
    var waitForCallbackCallsCount = 0
    var waitForCallbackCalled: Bool {
        waitForCallbackCallsCount > 0
    }
    var waitForCallbackReturnValue: OIDAuthorizationResponse!
    var waitForCallbackClosure: (() throws -> OIDAuthorizationResponse)?
    
    func waitForCallback() throws -> OIDAuthorizationResponse {
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
    var callbackResponseErrorReceivedArguments: (response: OIDAuthorizationResponse?, error: Error?)?
    var callbackResponseErrorReceivedInvocations: [(response: OIDAuthorizationResponse?, error: Error?)] = []
    var callbackResponseErrorClosure: ((OIDAuthorizationResponse?, Error?) -> Void)?
    
    func callback(response: OIDAuthorizationResponse?, error: Error?) {
        callbackResponseErrorCallsCount += 1
        callbackResponseErrorReceivedArguments = (response: response, error: error)
        callbackResponseErrorReceivedInvocations.append((response: response, error: error))
        callbackResponseErrorClosure?(response, error)
    }
}

