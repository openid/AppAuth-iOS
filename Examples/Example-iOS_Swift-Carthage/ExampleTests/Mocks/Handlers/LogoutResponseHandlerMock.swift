//
//  LogoutResponseHandlerMock.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All rights reserved.
//


import Foundation
import AppAuth
@testable import Example

// MARK: - LogoutResponseHandlerMock -

class LogoutResponseHandlerMock: LogoutResponseHandlerProtocol {
    var storedContinuation: CheckedContinuation<OIDEndSessionResponse, Error>?
    
    // MARK: - waitForCallback
    
    var waitForCallbackThrowableError: Error?
    var waitForCallbackCallsCount = 0
    var waitForCallbackCalled: Bool {
        waitForCallbackCallsCount > 0
    }
    var waitForCallbackReturnValue: OIDEndSessionResponse!
    var waitForCallbackClosure: (() throws -> OIDEndSessionResponse)?
    
    func waitForCallback() throws -> OIDEndSessionResponse {
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
    var callbackResponseErrorReceivedArguments: (response: OIDEndSessionResponse?, error: Error?)?
    var callbackResponseErrorReceivedInvocations: [(response: OIDEndSessionResponse?, error: Error?)] = []
    var callbackResponseErrorClosure: ((OIDEndSessionResponse?, Error?) -> Void)?
    
    func callback(response: OIDEndSessionResponse?, error: Error?) {
        callbackResponseErrorCallsCount += 1
        callbackResponseErrorReceivedArguments = (response: response, error: error)
        callbackResponseErrorReceivedInvocations.append((response: response, error: error))
        callbackResponseErrorClosure?(response, error)
    }
}
