//
//  LogoutResponseHandler.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import AppAuth

// MARK: LoginResponseHandlerProtocol
protocol LogoutResponseHandlerProtocol {
    var storedContinuation: CheckedContinuation<OIDEndSessionResponse, Error>? { get set }
    func waitForCallback() async throws -> OIDEndSessionResponse
    func callback(response: OIDEndSessionResponse?, error: Error?) -> Void
}

/*
 * A utility to manage Swift async await compatibility
 */
class LogoutResponseHandler: LogoutResponseHandlerProtocol {
    
    var storedContinuation: CheckedContinuation<OIDEndSessionResponse, Error>?
    
    /*
     * An async method to wait for the logout response to return
     */
    func waitForCallback() async throws -> OIDEndSessionResponse {
        
        try await withCheckedThrowingContinuation { continuation in
            storedContinuation = continuation
        }
    }
    
    /*
     * A callback that can be supplied to MainActor.run when triggering a logout redirect
     */
    func callback(response: OIDEndSessionResponse?, error: Error?) {
        
        if let error = error {
            storedContinuation?.resume(throwing: error)
        } else if let response = response {
            storedContinuation?.resume(returning: response)
        }
    }
}
