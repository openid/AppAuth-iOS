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

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    Button(authManager.hasAuthState ? "Re-Auth (Auto)" : "Auto") {
                        authManager.authWithAutoCodeExchange()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)

                    Button(authManager.hasAuthState ? "Re-Auth (Manual)" : "Manual") {
                        authManager.authNoCodeExchange()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }

                HStack {
                    Button("Code Exchange") {
                        authManager.codeExchange()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!authManager.hasAuthorizationCode)
                    .frame(maxWidth: .infinity)

                    Button("User Info") {
                        authManager.userinfo()
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
            .navigationTitle("AppAuth Example")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            authManager.clearAuthState()
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
