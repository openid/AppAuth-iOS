//
//  LogoutResponseHandler.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import AppAuth

/*
 * A utility to manage Swift async await compatibility
 */
class LogoutResponseHandler {

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

        if error != nil {
            storedContinuation?.resume(throwing: error!)
        } else {
            storedContinuation?.resume(returning: response!)
        }
    }
}
