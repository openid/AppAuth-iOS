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

    var currentAuthorizationFlow: OIDExternalUserAgentSession?

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Inspecting the error lets you distinguish a benign URL mismatch
        // (the URL belongs to another handler) from an unexpected condition
        // such as no pending flow, which previously surfaced as an NSException.
        if let authorizationFlow = self.currentAuthorizationFlow {
            do {
                try authorizationFlow.resumeExternalUserAgentFlow(with: url)
                self.currentAuthorizationFlow = nil
                return true
            } catch {
                print("Authorization flow could not handle URL: \(error.localizedDescription)")
            }
        }

        return false
    }
}
