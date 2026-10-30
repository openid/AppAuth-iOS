//
//  AppDelegate.swift
//
//  Copyright (c) 2026 The AppAuth Authors.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import AppAuth

class AppDelegate: NSObject, UIApplicationDelegate {

    /// The flows in progress, keyed by the label of the window that started each one.
    /// With one shared slot, a second window's flow would replace the first, and the first would be released mid-flow.
    var authorizationFlows: [String: OIDExternalUserAgentSession] = [:]

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Inspecting the error lets you distinguish a benign URL mismatch
        // (the URL belongs to another handler) from an unexpected condition
        // such as no pending flow, which previously surfaced as an NSException.
        // Each window has its own flow. Flows match on the redirect URI alone, so with two in progress the wrong one can take a response, and fail it on the state check.
        for (label, flow) in authorizationFlows {
            do {
                try flow.resumeExternalUserAgentFlow(url)
                authorizationFlows[label] = nil
                return true
            } catch {
                print("Authorization flow could not handle URL: \(error.localizedDescription)")
            }
        }

        return false
    }
}
