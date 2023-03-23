//
//  AuthStateResponseHandler.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import AppAuth

// MARK: LoginResponseHandlerProtocol
protocol AuthStateResponseHandlerProtocol {
    var storedContinuation: CheckedContinuation<OIDAuthState, Error>? { get set }
    func waitForCallback() async throws -> OIDAuthState
    func callback(response: OIDAuthState?, error: Error?) -> Void
}

/*
 * A utility to manage Swift async await compatibility
 */
class AuthStateResponseHandler: AuthStateResponseHandlerProtocol {
    
    var storedContinuation: CheckedContinuation<OIDAuthState, Error>?
    
    /*
     * An async method to wait for the AuthState response to return
     */
    func waitForCallback() async throws -> OIDAuthState {
        
        try await withCheckedThrowingContinuation { continuation in
            storedContinuation = continuation
        }
    }
    
    /*
     * A callback that can be supplied to MainActor.run when
     * triggering an AuthState related request
     */
    func callback(response: OIDAuthState?, error: Error?) {
        
        if let error = error {
            storedContinuation?.resume(throwing: error)
        } else if let response = response {
            storedContinuation?.resume(returning: response)
        }
    }
}
