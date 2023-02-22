//
//  ConcurrencyHandler.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation

class ConcurrencyHandler {

    private typealias SuccessCallback = () -> Void
    private typealias ErrorCallback = (Error) -> Void

    private var callbacks: [(SuccessCallback, ErrorCallback)]
    private let queue: DispatchQueue

    /*
     * Initialise the array of promises
     */
    init() {
        self.callbacks = []
        self.queue = DispatchQueue(label: "ConcurrentArray")
    }

    /*
     * Run the supplied action the first time only and return a promise to the caller
     */
    func execute(action: () async throws -> Void) async throws {

        // Create callbacks through which we'll return the result for this caller
        let onSuccess: SuccessCallback = {
        }
        let onError: ErrorCallback = { _ in
        }

        // Add the callback to the collection, in a thread safe manner
        queue.sync {
            self.callbacks.append((onSuccess, onError))
        }

        // Perform the action for the first caller only
        if self.callbacks.count == 1 {

            do {

                // Do the work
                try await action()

                // Resolve all promises with the same success result
                queue.sync {
                    self.callbacks.forEach { callback in
                        callback.0()
                    }
                }

            } catch {

                // Resolve all promises with the same error
                let authError = AuthError.api(message: error.localizedDescription, underlyingError: error)
                queue.sync {
                    self.callbacks.forEach { callback in
                        callback.1(authError)
                    }
                }
            }

            // Reset once complete
            queue.sync {
                self.callbacks = []
            }
        }
    }
}
