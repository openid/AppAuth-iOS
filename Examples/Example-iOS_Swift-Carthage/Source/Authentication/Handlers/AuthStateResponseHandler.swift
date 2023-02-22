//
//  AuthStateResponseHandler.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import AppAuth

/*
 * A utility to manage Swift async await compatibility
 */
class AuthStateResponseHandler {

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

        if error != nil {
            storedContinuation?.resume(throwing: error!)
        } else {
            storedContinuation?.resume(returning: response!)
        }
    }
}
