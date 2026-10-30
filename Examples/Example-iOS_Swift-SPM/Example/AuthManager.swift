//
//  AuthManager.swift
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

import AppAuth
import Combine
import SwiftUI
import UIKit

typealias PostRegistrationCallback = (OIDServiceConfiguration?, OIDRegistrationResponse?) -> Void

let kIssuer: String = {
    guard let issuer = Bundle.main.object(forInfoDictionaryKey: "OIDCIssuer") as? String,
          !issuer.isEmpty,
          issuer != "https://issuer.example.com" else {
        preconditionFailure("Please configure OIDC_ISSUER in Example.local.xcconfig")
    }
    return issuer
}()
let kClientID: String? = {
    let clientID = Bundle.main.object(forInfoDictionaryKey: "OIDCClientID") as? String
    if clientID == "YOUR_CLIENT_ID" || clientID?.isEmpty ?? true {
        return nil
    }
    return clientID
}()
let kRedirectURI: String = {
    guard let redirectURI = Bundle.main.object(forInfoDictionaryKey: "OIDCRedirectURI") as? String,
          !redirectURI.isEmpty,
          redirectURI != "com.example.app:/oauth2redirect/example-provider" else {
        preconditionFailure("Please configure OIDC_REDIRECT_URI in Example.local.xcconfig")
    }
    return redirectURI
}()
let kAppAuthExampleAuthStateKey: String = "authState"

/// One window of the sample. Flows started in it present in it, and its log lines carry its label.
final class SampleWindow {
    /// A short label for this window, shown in its title and on its log lines.
    let label: String = String(UUID().uuidString.prefix(4))

    /// A view controller in this window. Flows started here present from it.
    weak var presentingViewController: UIViewController?
}

final class AuthManager: NSObject, ObservableObject {
    @Published private(set) var authState: OIDAuthState?
    @Published private(set) var logText: String = ""

    var isAuthorized: Bool { authState?.isAuthorized ?? false }
    var hasAuthorizationCode: Bool { authState?.lastAuthorizationResponse.authorizationCode != nil && authState?.lastTokenResponse == nil }
    var hasAuthState: Bool { authState != nil }

    weak var appDelegate: AppDelegate?

    override init() {
        super.init()
        self.validateOAuthConfiguration()
        self.loadState()
    }

    // MARK: Public Methods

    func validateOAuthConfiguration() {
        guard let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]],
              let urlSchemes = urlTypes.first?["CFBundleURLSchemes"] as? [String],
              let urlScheme = urlSchemes.first else {
            assertionFailure("CFBundleURLSchemes not configured")
            return
        }

        assert(urlScheme != "com.example.app", "Register your OIDC Redirect URI scheme in Example.local.xcconfig (OIDC_REDIRECT_URI_SCHEME).")
        assert(kIssuer != "https://issuer.example.com", "Register your OIDC Issuer in Example.local.xcconfig (OIDC_ISSUER).")
    }

    func authWithAutoCodeExchange(from sampleWindow: SampleWindow) {
        guard let issuer = URL(string: kIssuer) else {
            self.logMessage("Error creating URL for : \(kIssuer)", from: sampleWindow)
            return
        }

        self.logMessage("Fetching configuration for issuer: \(issuer)", from: sampleWindow)

        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            guard let config = configuration else {
                self.logMessage("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")", from: sampleWindow)
                self.setAuthState(nil)
                return
            }

            self.logMessage("Got configuration: \(config)", from: sampleWindow)

            // If kClientID was provided, use it; otherwise perform RFC 7591 dynamic client registration.
            if let clientId = kClientID {
                self.doAuthWithAutoCodeExchange(configuration: config, clientID: clientId, clientSecret: nil, from: sampleWindow)
            } else {
                self.doClientRegistration(configuration: config, from: sampleWindow) { configuration, response in
                    guard let configuration = configuration, let clientID = response?.clientID else {
                        self.logMessage("Error retrieving configuration OR clientID", from: sampleWindow)
                        return
                    }

                    self.doAuthWithAutoCodeExchange(configuration: configuration,
                                                    clientID: clientID,
                                                    clientSecret: response?.clientSecret,
                                                    from: sampleWindow)
                }
            }
        }
    }

    func authNoCodeExchange(from sampleWindow: SampleWindow) {
        guard let issuer = URL(string: kIssuer) else {
            self.logMessage("Error creating URL for : \(kIssuer)", from: sampleWindow)
            return
        }

        self.logMessage("Fetching configuration for issuer: \(issuer)", from: sampleWindow)

        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            if let error = error  {
                self.logMessage("Error retrieving discovery document: \(error.localizedDescription)", from: sampleWindow)
                return
            }

            guard let configuration = configuration else {
                self.logMessage("Error retrieving discovery document. Error & Configuration both are NIL!", from: sampleWindow)
                return
            }

            self.logMessage("Got configuration: \(configuration)", from: sampleWindow)

            // If kClientID was provided, use it; otherwise perform RFC 7591 dynamic client registration.
            if let clientId = kClientID {
                self.doAuthWithoutCodeExchange(configuration: configuration, clientID: clientId, clientSecret: nil, from: sampleWindow)
            } else {
                self.doClientRegistration(configuration: configuration, from: sampleWindow) { configuration, response in
                    guard let configuration = configuration, let response = response else {
                        return
                    }

                    self.doAuthWithoutCodeExchange(configuration: configuration,
                                                   clientID: response.clientID,
                                                   clientSecret: response.clientSecret,
                                                   from: sampleWindow)
                }
            }
        }
    }

    func codeExchange(from sampleWindow: SampleWindow) {
        guard let tokenExchangeRequest = self.authState?.lastAuthorizationResponse.tokenExchangeRequest() else {
            self.logMessage("Error creating authorization code exchange request", from: sampleWindow)
            return
        }

        self.logMessage("Performing authorization code exchange with request \(tokenExchangeRequest)", from: sampleWindow)

        OIDAuthorizationService.perform(tokenExchangeRequest) { response, error in
            if let tokenResponse = response {
                self.logMessage("Received token response with accessToken: \(tokenResponse.accessToken ?? "DEFAULT_TOKEN")", from: sampleWindow)
            } else {
                self.logMessage("Token exchange error: \(error?.localizedDescription ?? "DEFAULT_ERROR")", from: sampleWindow)
            }
            self.authState?.update(with: response, error: error)
        }
    }

    func userinfo(from sampleWindow: SampleWindow) {
        guard let userinfoEndpoint = self.authState?.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint else {
            self.logMessage("Userinfo endpoint not declared in discovery document", from: sampleWindow)
            return
        }

        self.logMessage("Performing userinfo request", from: sampleWindow)

        let currentAccessToken: String? = self.authState?.lastTokenResponse?.accessToken

        self.authState?.performAction() { (accessToken, idToken, error) in
            if error != nil  {
                self.logMessage("Error fetching fresh tokens: \(error?.localizedDescription ?? "ERROR")", from: sampleWindow)
                return
            }

            guard let accessToken = accessToken else {
                self.logMessage("Error getting accessToken", from: sampleWindow)
                return
            }

            if currentAccessToken != accessToken {
                self.logMessage("Access token was refreshed automatically (\(currentAccessToken ?? "CURRENT_ACCESS_TOKEN") to \(accessToken))", from: sampleWindow)
            } else {
                self.logMessage("Access token was fresh and not updated \(accessToken)", from: sampleWindow)
            }

            var urlRequest = URLRequest(url: userinfoEndpoint)
            urlRequest.allHTTPHeaderFields = ["Authorization":"Bearer \(accessToken)"]

            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                DispatchQueue.main.async {
                    guard error == nil else {
                        self.logMessage("HTTP request failed \(error?.localizedDescription ?? "ERROR")", from: sampleWindow)
                        return
                    }

                    guard let response = response as? HTTPURLResponse else {
                        self.logMessage("Non-HTTP response", from: sampleWindow)
                        return
                    }

                    guard let data = data else {
                        self.logMessage("HTTP response data is empty", from: sampleWindow)
                        return
                    }

                    var json: [AnyHashable: Any]?

                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    } catch {
                        self.logMessage("JSON Serialization Error", from: sampleWindow)
                    }

                    if response.statusCode != 200 {
                        // server replied with an error
                        let responseText: String? = String(data: data, encoding: String.Encoding.utf8)

                        if response.statusCode == 401 {
                            // "401 Unauthorized" generally indicates there is an issue with the authorization
                            // grant. Puts OIDAuthState into an error state.
                            let oauthError = OIDErrorUtilities.resourceServerAuthorizationError(withCode: 0,
                                                                                                errorResponse: json,
                                                                                                underlyingError: error)
                            self.authState?.update(withAuthorizationError: oauthError)
                            self.logMessage("Authorization Error (\(oauthError)). Response: \(responseText ?? "RESPONSE_TEXT")", from: sampleWindow)
                        } else {
                            self.logMessage("HTTP: \(response.statusCode), Response: \(responseText ?? "RESPONSE_TEXT")", from: sampleWindow)
                        }

                        return
                    }

                    if let json = json {
                        self.logMessage("Success: \(json)", from: sampleWindow)
                    }
                }
            }

            task.resume()
        }
    }

    func clearAuthState(from sampleWindow: SampleWindow) {
        setAuthState(nil)
        self.logMessage("Cleared OAuth state", from: sampleWindow)
    }

    func clearLogs() {
        DispatchQueue.main.async {
            self.logText = ""
        }
    }

    // MARK: Private Methods

    private func doClientRegistration(configuration: OIDServiceConfiguration, from sampleWindow: SampleWindow, callback: @escaping PostRegistrationCallback) {
        guard let redirectURI = URL(string: kRedirectURI) else {
            self.logMessage("Error creating URL for : \(kRedirectURI)", from: sampleWindow)
            return
        }

        let request: OIDRegistrationRequest = OIDRegistrationRequest(configuration: configuration,
                                                                     redirectURIs: [redirectURI],
                                                                     responseTypes: nil,
                                                                     grantTypes: nil,
                                                                     subjectType: nil,
                                                                     tokenEndpointAuthMethod: "client_secret_post",
                                                                     additionalParameters: nil)

        // performs registration request
        self.logMessage("Initiating registration request", from: sampleWindow)

        OIDAuthorizationService.perform(request) { response, error in
            if let regResponse = response {
                self.setAuthState(OIDAuthState(registrationResponse: regResponse))
                self.logMessage("Got registration response: \(regResponse)", from: sampleWindow)
                callback(configuration, regResponse)
            } else {
                self.logMessage("Registration error: \(error?.localizedDescription ?? "DEFAULT_ERROR")", from: sampleWindow)
                self.setAuthState(nil)
            }
        }
    }

    private func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?, from sampleWindow: SampleWindow) {
        guard let redirectURI = URL(string: kRedirectURI) else {
            self.logMessage("Error creating URL for : \(kRedirectURI)", from: sampleWindow)
            return
        }

        guard let appDelegate = self.appDelegate else {
            self.logMessage("Error accessing AppDelegate", from: sampleWindow)
            return
        }

        guard let presentingVC = sampleWindow.presentingViewController else {
            self.logMessage("Error: no presenting view controller available", from: sampleWindow)
            return
        }

        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)

        // performs authentication request
        logMessage("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")", from: sampleWindow)

        appDelegate.authorizationFlows[sampleWindow.label] = OIDAuthState.authState(byPresenting: request, presenting: presentingVC) { authState, error in
            // releases this window's finished flow
            self.appDelegate?.authorizationFlows[sampleWindow.label] = nil
            if let authState = authState {
                self.setAuthState(authState)
                self.logMessage("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")", from: sampleWindow)
            } else {
                self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")", from: sampleWindow)
                self.setAuthState(nil)
            }
        }
    }

    private func doAuthWithoutCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?, from sampleWindow: SampleWindow) {
        guard let redirectURI = URL(string: kRedirectURI) else {
            self.logMessage("Error creating URL for : \(kRedirectURI)", from: sampleWindow)
            return
        }

        guard let appDelegate = self.appDelegate else {
            self.logMessage("Error accessing AppDelegate", from: sampleWindow)
            return
        }

        guard let presentingVC = sampleWindow.presentingViewController else {
            self.logMessage("Error: no presenting view controller available", from: sampleWindow)
            return
        }

        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)

        // performs authentication request
        logMessage("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")", from: sampleWindow)

        appDelegate.authorizationFlows[sampleWindow.label] = OIDAuthorizationService.present(request, presenting: presentingVC) { (response, error) in
            // releases this window's finished flow
            self.appDelegate?.authorizationFlows[sampleWindow.label] = nil
            if let response = response {
                let authState = OIDAuthState(authorizationResponse: response)
                self.setAuthState(authState)
                self.logMessage("Authorization response with code: \(response.authorizationCode ?? "DEFAULT_CODE")", from: sampleWindow)
                // could just call [self tokenExchange:nil] directly, but will let the user initiate it.
            } else {
                self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")", from: sampleWindow)
            }
        }
    }

    private func setAuthState(_ authState: OIDAuthState?) {
        if (self.authState == authState) {
            return
        }
        self.authState = authState
        self.authState?.stateChangeDelegate = self
        self.authState?.errorDelegate = self
        self.stateChanged()
    }

    private func stateChanged() {
        self.saveState()
    }

    private func saveState() {
        var data: Data? = nil

        if let authState = self.authState {
            do {
                data = try NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: true)
            } catch {
                logMessage("Error archiving authState: \(error.localizedDescription)")
                return
            }
        }

        UserDefaults.standard.set(data, forKey: kAppAuthExampleAuthStateKey)
    }

    private func loadState() {
        guard let data = UserDefaults.standard.data(forKey: kAppAuthExampleAuthStateKey) else {
            return
        }

        do {
            if let authState = try NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data) {
                self.setAuthState(authState)
            }
        } catch {
            logMessage("Error unarchiving authState: \(error.localizedDescription)")
        }
    }

    private func logMessage(_ message: String?, from sampleWindow: SampleWindow? = nil) {
        guard let message = message else {
            return
        }

        let prefix = sampleWindow.map { "[\($0.label)] " } ?? ""
        print("\(prefix)\(message)")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        let dateString = dateFormatter.string(from: Date())

        // appends to output log
        DispatchQueue.main.async {
            let logText = "\(self.logText)\n\(dateString): \(prefix)\(message)"
            self.logText = logText
        }
    }
}

// MARK: OIDAuthState Delegate

extension AuthManager: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    func didChange(_ state: OIDAuthState) {
        self.stateChanged()
    }

    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        self.logMessage("Received authorization error: \(error)")
    }
}
