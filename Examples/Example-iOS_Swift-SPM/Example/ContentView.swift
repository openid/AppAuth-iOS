//
//  ContentView.swift
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

import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var sampleWindow = SampleWindow()
    @Environment(\.openWindow) private var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    Button(authManager.hasAuthState ? "Re-Auth (Auto)" : "Auto") {
                        authManager.authWithAutoCodeExchange(from: sampleWindow)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)

                    Button(authManager.hasAuthState ? "Re-Auth (Manual)" : "Manual") {
                        authManager.authNoCodeExchange(from: sampleWindow)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }

                HStack {
                    Button("Code Exchange") {
                        authManager.codeExchange(from: sampleWindow)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!authManager.hasAuthorizationCode)
                    .frame(maxWidth: .infinity)

                    Button("User Info") {
                        authManager.userinfo(from: sampleWindow)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!authManager.isAuthorized)
                    .frame(maxWidth: .infinity)
                }

                ScrollViewReader { proxy in
                    ScrollView {
                        Text(authManager.logText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .padding(8)
                            .id("bottom")
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.4))
                    )
                    .onChange(of: authManager.logText) { _ in
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            .padding()
            .background(PresentingViewControllerReader(sampleWindow: sampleWindow))
            .navigationTitle("AppAuth Example (\(sampleWindow.label))")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // hidden where this app can't open a second window
                    if supportsMultipleWindows {
                        Button {
                            openWindow(id: ExampleApp.windowGroupID)
                        } label: {
                            Image(systemName: "plus.rectangle.on.rectangle")
                        }
                        .accessibilityLabel("New Window")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            authManager.clearAuthState(from: sampleWindow)
                        } label: {
                            Text("Clear OAuth State")
                        }
                        
                        Button {
                            authManager.clearLogs()
                        } label: {
                            Text("Clear Logs")
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
}

/// Puts an empty view controller into this window, and hands it to the SampleWindow.
/// The browser sheet is anchored to its presenting view controller's window, so it opens in the window that asked.
struct PresentingViewControllerReader: UIViewControllerRepresentable {
    let sampleWindow: SampleWindow

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        sampleWindow.presentingViewController = viewController
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
