//
//  LoginResponseHandler.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import AppAuth

// MARK: LoginResponseHandlerProtocol
protocol LoginResponseHandlerProtocol {
    var storedContinuation: CheckedContinuation<OIDAuthorizationResponse, Error>? { get set }
    func waitForCallback() async throws -> OIDAuthorizationResponse
    func callback(response: OIDAuthorizationResponse?, error: Error?) -> Void
}

/*
 * A utility to manage Swift async await compatibility
 */
class LoginResponseHandler: LoginResponseHandlerProtocol {
    
    var storedContinuation: CheckedContinuation<OIDAuthorizationResponse, Error>?
    
    /*
     * An async method to wait for the login response to return
     */
    func waitForCallback() async throws -> OIDAuthorizationResponse {
        
        try await withCheckedThrowingContinuation { continuation in
            storedContinuation = continuation
        }
    }
    
    /*
     * A callback that can be supplied to MainActor.run when triggering a login redirect
     */
    func callback(response: OIDAuthorizationResponse?, error: Error?) {
        
        if let error = error {
            storedContinuation?.resume(throwing: error)
        } else if let response = response {
            storedContinuation?.resume(returning: response)
        }
    }
}
