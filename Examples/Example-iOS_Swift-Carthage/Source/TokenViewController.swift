//
//  TokenViewController.swift
//
//  Copyright (c) 2017 The AppAuth Authors.
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
import UIKit


typealias CompletionCallback = (_ completed: Bool, _ error: Error?) -> Void

/**
 The OAuth logout URI for the client @c kClientID.

 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kLogoutURI: String? = "https://api.multi.dev.or.janrain.com/00000000-0000-0000-0000-000000000000/auth-ui/logout"

/**
 The OAuth revoke token URI for the client @c kClientID.
 */
let kRevokeTokenURI: String? = "https://api.multi.dev.or.janrain.com/00000000-0000-0000-0000-000000000000/login/token/revoke"

/**
 The Profile Management URI for the client @c kClientID.

 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kProfileURI: String? = "https://api.multi.dev.or.janrain.com/00000000-0000-0000-0000-000000000000/auth-ui/profile"

class TokenViewController: UIViewController {

    @IBOutlet private weak var codeExchangeButton: UIButton!
    @IBOutlet private weak var userinfoButton: UIButton!
    @IBOutlet private weak var refreshTokenButton: UIButton!
    @IBOutlet private weak var browserButton: UIButton!
    @IBOutlet private weak var profileButton: UIButton!
    @IBOutlet private weak var logTextView: UITextView!

    @IBOutlet private weak var accessTokenTitleLabel: UILabel!
    @IBOutlet private weak var refreshTokenTitleLabel: UILabel!
    @IBOutlet private weak var accessTokenTextView: UITextView!
    @IBOutlet private weak var refreshTokenTextView: UITextView!
    @IBOutlet private weak var accessTokenStackView: UIStackView!
    @IBOutlet private weak var refreshTokenStackView: UIStackView!
    @IBOutlet private weak var tokenStackView: UIStackView!

    private var authState: OIDAuthState?
    private var isAccessTokenRevoked = false
    private var isRefreshTokenRevoked = false
    private var isBrowserSessionRevoked = false

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        validateOAuthConfiguration()
        configureAdditionalParameters()

        loadAppState()
        updateUI()
    }
}

extension TokenViewController {

    func validateOAuthConfiguration() {

        // The example needs to be configured with your own client details.
        // See: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md

        assert(kIssuer != "https://issuer.example.com",
               "Update kIssuer with your own issuer.\n" +
               "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md")

        assert(kClientID != "YOUR_CLIENT_ID",
               "Update kClientID with your own client ID.\n" +
               "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md")

        assert(kRedirectURI != "com.example.app:/oauth2redirect/example-provider",
               "Update kRedirectURI with your own redirect URI.\n" +
               "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md")

        // verifies that the custom URI scheme has been updated in the Info.plist
        guard let urlTypes: [AnyObject] = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [AnyObject], urlTypes.count > 0 else {
            assertionFailure("No custom URI scheme has been configured for the project.")
            return
        }

        guard let items = urlTypes[0] as? [String: AnyObject],
              let urlSchemes = items["CFBundleURLSchemes"] as? [AnyObject], urlSchemes.count > 0 else {
            assertionFailure("No custom URI scheme has been configured for the project.")
            return
        }

        guard let urlScheme = urlSchemes[0] as? String else {
            assertionFailure("No custom URI scheme has been configured for the project.")
            return
        }

        assert(urlScheme != "com.example.app",
               "Configure the URI scheme in Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0) " +
               "with the scheme of your redirect URI. Full instructions: " +
               "https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md")
    }

    func configureAdditionalParameters() {

        if kPrompt != nil {
            kAdditionalParamaters["prompt"] = kPrompt
        }

        if kClaims != nil {
            kAdditionalParamaters["claims"] = kClaims
        }

        if kAcrValues != nil {
            kAdditionalParamaters["acr_values"] = kAcrValues
        }
    }

    func configureUI() {
        logTextView.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        logTextView.layer.borderWidth = 1.0
        logTextView.alwaysBounceVertical = true
        logTextView.textContainer.lineBreakMode = .byCharWrapping
        logTextView.text = ""

        accessTokenTextView.delegate = self
        refreshTokenTextView.delegate = self
    }
}

//MARK: IBActions
extension TokenViewController {

    @IBAction func authWithAutoCodeExchange(_ sender: UIButton) {

        guard let issuer = URL(string: kIssuer) else {
            logMessage("Error creating URL for : \(kIssuer)")
            return
        }

        logMessage("Fetching configuration for issuer: \(issuer)")

        // discovers endpoints
        discoverConfig() { configuration, clientId, clientSecret in

            guard let config = configuration else {
                self.logMessage("Error retrieving discovery document")
                self.setAuthState(nil)
                return
            }

            self.logMessage("Got configuration: \(config)")

            if let clientId = kClientID {
                self.doAuthWithAutoCodeExchange(configuration: config, clientID: clientId, clientSecret: nil)
            } else {
                self.doClientRegistration(configuration: config) { configuration, response in

                    guard let configuration = configuration, let clientID = response?.clientID else {
                        self.logMessage("Error retrieving configuration OR clientID")
                        return
                    }

                    self.doAuthWithAutoCodeExchange(configuration: configuration,
                                                    clientID: clientID,
                                                    clientSecret: response?.clientSecret)
                }
            }
        }
    }

    @IBAction func codeExchange(_ sender: UIButton) {

        guard let tokenExchangeRequest = self.authState?.lastAuthorizationResponse.tokenExchangeRequest() else {
            logMessage("Error creating authorization code exchange request")
            return
        }

        logMessage("Performing authorization code exchange with request \(tokenExchangeRequest)")

        OIDAuthorizationService.perform(tokenExchangeRequest) { response, error in

            if let tokenResponse = response {
                self.logMessage("Received token response with accessToken: \(tokenResponse.accessToken ?? "DEFAULT_TOKEN")")
            } else {
                self.logMessage("Token exchange error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
            }
            self.authState?.update(with: response, error: error)
        }
    }

    @IBAction func userinfo(_ sender: UIButton) {

        guard let userinfoEndpoint = authState?.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint else {
            logMessage("Userinfo endpoint not declared in discovery document")
            return
        }

        logMessage("Performing userinfo request")

        let currentAccessToken: String? = authState?.lastTokenResponse?.accessToken

        authState?.performAction() { (accessToken, idToken, error) in

            if error != nil  {
                self.logMessage("Error fetching fresh tokens: \(error?.localizedDescription ?? "ERROR")")
                self.isAccessTokenRevoked = true
                self.isRefreshTokenRevoked = true

                return
            }

            guard let accessToken = accessToken else {
                self.logMessage("Error getting accessToken")
                return
            }

            if currentAccessToken != accessToken {
                self.logMessage("Access token was refreshed automatically (\(currentAccessToken ?? "CURRENT_ACCESS_TOKEN") to \(accessToken))")
            } else {
                self.logMessage("Access token was fresh and not updated \(accessToken)")
            }

            var urlRequest = URLRequest(url: userinfoEndpoint)
            urlRequest.allHTTPHeaderFields = ["Authorization":"Bearer \(accessToken)"]

            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in

                DispatchQueue.main.async {

                    guard error == nil else {
                        self.logMessage("HTTP request failed \(error?.localizedDescription ?? "ERROR")")
                        return
                    }

                    guard let response = response as? HTTPURLResponse else {
                        self.logMessage("Non-HTTP response")
                        return
                    }

                    guard let data = data else {
                        self.logMessage("HTTP response data is empty")
                        return
                    }

                    var json: [AnyHashable: Any]?

                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    } catch {
                        self.logMessage("JSON Serialization Error")
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
                            self.logMessage("Authorization Error (\(oauthError)). Response: \(responseText ?? "RESPONSE_TEXT")")
                        } else {
                            self.logMessage("HTTP: \(response.statusCode), Response: \(responseText ?? "RESPONSE_TEXT")")
                        }

                        return
                    }

                    if let json = json {
                        self.logMessage("Success: \(json)")
                    }
                }
            }

            task.resume()
        }
    }

    @IBAction func refreshToken(_ sender: UIButton) {

        guard let tokenRefreshRequest = authState?.tokenRefreshRequest() else {
            logMessage("Error creating token refresh request")
            return
        }

        logMessage("Performing token refresh with request \(tokenRefreshRequest)")

        OIDAuthorizationService.perform(tokenRefreshRequest) { response, error in

            if let tokenResponse = response {
                self.logMessage("Received token response with accessToken: \(tokenResponse.accessToken ?? "DEFAULT_TOKEN")")
                self.authState?.update(with: tokenResponse, error: error)
            } else {
                self.logMessage("Token refresh error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
    }

    @IBAction func profileManagement(_ sender: UIButton) {

        guard let issuer = URL(string: kIssuer) else {
            logMessage("Error creating URL for : \(kIssuer)")
            return
        }

        logMessage("Fetching configuration for issuer: \(issuer)")

        // discovers endpoints
        discoverConfig() { configuration, clientId, clientSecret in

            guard let config = configuration else {
                self.logMessage("Error retrieving discovery document")
                self.setAuthState(nil)
                return
            }

            self.logMessage("Got configuration: \(config)")

            if let clientId = kClientID {
                self.loadProfileManagement(configuration: config, clientID: clientId, clientSecret: nil)
            } else {
                self.doClientRegistration(configuration: config) { configuration, response in

                    guard let configuration = configuration, let clientID = response?.clientID else {
                        self.logMessage("Error retrieving configuration OR clientID")
                        return
                    }

                    self.loadProfileManagement(configuration: configuration,
                                               clientID: clientID,
                                               clientSecret: response?.clientSecret)
                }
            }
        }
    }

    @IBAction func logout(_ sender: UIButton) {
        displayLogoutAlert()
    }

    @IBAction func clearLog(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.logTextView.text = ""
        }
    }

    func revokeAccessToken(accessToken: String, completion: @escaping CompletionCallback) {

        guard let revokeTokenUriString = kRevokeTokenURI, let revokeTokenUri = URL(string: revokeTokenUriString) else { return }
        var request = URLRequest(url: revokeTokenUri)
        request.httpMethod = "POST"

        guard let clientId = kClientID else { return }
        let bodyString = "token=\(accessToken)&client_id=\(clientId)"
        let bodyData = bodyString.data(using: .utf8)!
        let bodyLength = "\(bodyData.count)"
        request.httpBody = bodyData
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(bodyLength, forHTTPHeaderField: "Content-Length")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let message = String(data: data, encoding: .utf8)!
                print(message)
                DispatchQueue.main.async {
                    self.logMessage(message)
                }
                completion(true, nil)
            } else if let error = error {
                print("Revoke Token Error: \(error)")
                completion(true, error)
            }
        }
        task.resume()
    }

    func revokeRefreshToken(refreshToken: String, completion: @escaping CompletionCallback) {

        guard let revokeTokenUriString = kRevokeTokenURI, let revokeTokenUri = URL(string: revokeTokenUriString) else { return }
        var request = URLRequest(url: revokeTokenUri)
        request.httpMethod = "POST"

        guard let clientId = kClientID else { return }
        let bodyString = "token=\(refreshToken)&client_id=\(clientId)"
        let bodyData = bodyString.data(using: .utf8)!
        let bodyLength = "\(bodyData.count)"
        request.httpBody = bodyData
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(bodyLength, forHTTPHeaderField: "Content-Length")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let message = String(data: data, encoding: .utf8)!
                print(message)
                DispatchQueue.main.async {
                    self.logMessage(message)
                }
            } else if let error = error {
                print("Revoke Token Error: \(error)")
            }

            completion(true, error)
        }
        task.resume()
    }
}

//MARK: AppAuth Methods
extension TokenViewController {

    func discoverConfig(callback: @escaping PostDiscoveryCallback) {

        guard let issuer = URL(string: kIssuer) else {
            logMessage("Error creating URL for : \(kIssuer)")
            updateUI()
            return
        }

        logMessage("Fetching configuration for issuer: \(issuer)")

        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in

            if let error = error  {
                self.logMessage("Error retrieving discovery document: \(error.localizedDescription)")
                self.updateUI()
                return
            }

            guard let configuration = configuration else {
                self.logMessage("Error retrieving discovery document. Error & Configuration both are NIL!")
                self.updateUI()
                return
            }

            self.logMessage("Got configuration: \(configuration)")

            if let clientId = kClientID {

                callback(configuration, clientId, nil)

            } else {

                self.doClientRegistration(configuration: configuration) { configuration, response in

                    guard let configuration = configuration, let response = response else {
                        return
                    }

                    callback(configuration, response.clientID, response.clientSecret)
                }
            }
        }
    }

    func doClientRegistration(configuration: OIDServiceConfiguration, callback: @escaping PostRegistrationCallback) {

        guard let redirectURI = URL(string: kRedirectURI) else {
            logMessage("Error creating URL for : \(kRedirectURI)")
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
        logMessage("Initiating registration request")

        OIDAuthorizationService.perform(request) { response, error in

            if let regResponse = response {
                self.setAuthState(OIDAuthState(registrationResponse: regResponse))
                self.logMessage("Got registration response: \(regResponse)")
                callback(configuration, regResponse)
            } else {
                self.logMessage("Registration error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
    }

    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {

        guard let redirectURI = URL(string: kRedirectURI) else {
            logMessage("Error creating URL for : \(kRedirectURI)")
            return
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            logMessage("Error accessing AppDelegate")
            return
        }

        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: kScopes,
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: kAdditionalParamaters)
        // performs authentication request
        logMessage("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")

        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self) { authState, error in

            if let authState = authState {
                self.isRefreshTokenRevoked = false
                self.isAccessTokenRevoked = false
                self.isBrowserSessionRevoked = false
                self.setAuthState(authState)
                self.logMessage("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
            } else {
                self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                if self.isBrowserSessionRevoked {
                    self.endAppSession()
                }
            }
        }
    }

    func loadProfileManagement(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {

        guard let redirectURI = URL(string: kRedirectURI) else {
            logMessage("Error creating URL for : \(kRedirectURI)")
            return
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            logMessage("Error accessing AppDelegate")
            return
        }

        guard let profileUriString = kProfileURI,
              !profileUriString.isEmpty,
              let profileUri = URL(string: profileUriString)
        else {
            logMessage("Error accessing kProfileUri")
            return
        }

        // create the config for profile management
        let profileConfig = OIDServiceConfiguration(
            authorizationEndpoint: profileUri,
            tokenEndpoint: configuration.tokenEndpoint,
            issuer: configuration.issuer,
            registrationEndpoint: configuration.registrationEndpoint,
            endSessionEndpoint: configuration.endSessionEndpoint)

        logMessage("Initiating profile management request with config: \(profileConfig)")

        // builds profile management request
        let request = OIDAuthorizationRequest(configuration: profileConfig,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: kScopes,
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: kAdditionalParamaters)
        // performs profile management request
        logMessage("Initiating profile management request with scope: \(request.scope ?? "DEFAULT_SCOPE")")

        guard let userAgent = OIDExternalUserAgentIOS(presenting: self) else {
            logMessage("Error retrieving user agent")
            return
        }

        appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(request, externalUserAgent: userAgent) { (response, error) in

            if let logoutResponse = response {
                self.logMessage("Got profile management response: \(logoutResponse)")
            }  else {
                self.logMessage("profile management error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
            }
            self.accessTokenTitleLabel.text = "No access token returned"
            self.refreshTokenTitleLabel.text = "No refresh token returned"
            self.accessTokenTextView.text = ""
            self.refreshTokenTextView.text = ""
        }
    }

    func endBrowserSession(completion: @escaping CompletionCallback) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                self.logMessage("Error accessing AppDelegate")
                return
            }

            guard let redirectURI = URL(string: kRedirectURI) else {
                self.logMessage("Error creating URL for : \(kRedirectURI)")
                return
            }

            guard let logoutUriString = kLogoutURI,
                  !logoutUriString.isEmpty,
                  let logoutUri = URL(string: logoutUriString)
            else {
                self.logMessage("Error accessing kLogoutUri")
                return
            }

            self.discoverConfig() { configuration, clientId, clientSecret in

                guard let configuration = configuration else {
                    self.logMessage("Error retrieving discovery document. Error & Configuration both are NIL!")
                    return
                }

                let tokenHint = self.authState?.lastTokenResponse?.idToken ?? ""

                // create the config for logout
                let logoutConfig = OIDServiceConfiguration(
                    authorizationEndpoint: configuration.authorizationEndpoint,
                    tokenEndpoint: configuration.tokenEndpoint,
                    issuer: configuration.issuer,
                    registrationEndpoint: configuration.registrationEndpoint,
                    endSessionEndpoint: logoutUri)

                let logoutAdditionalParams = [
                    "client_id": clientId]

                // builds the end session request
                let endSessionRequest = OIDEndSessionRequest(configuration: logoutConfig, idTokenHint: tokenHint, postLogoutRedirectURL: redirectURI, additionalParameters: logoutAdditionalParams)

                guard let userAgent = OIDExternalUserAgentIOS(presenting: self) else {
                    self.logMessage("Error retrieving user agent")
                    return
                }

                // opens the browser to clear auth sessionendSessionRequest  OIDEndSessionRequest
                appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(endSessionRequest, externalUserAgent: userAgent) { (response, error) in
                    if let logoutResponse = response {
                        self.logMessage("Got logout response: \(logoutResponse)")
                        completion(true, nil)
                    }  else {
                        self.logMessage("Logout error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                        completion(true, error)
                    }
                }
            }
        }
    }

    func endAppSession() {
        DispatchQueue.main.async {
            self.isAccessTokenRevoked = false;
            self.isRefreshTokenRevoked = false;
            self.isBrowserSessionRevoked = false;
            self.setAuthState(nil)
            UIApplication.setRootView(AppAuthExampleViewController.instantiate(from: .Main), options: UIApplication.logoutAnimation)
        }
    }
}

//MARK: OIDAuthState Delegate
extension TokenViewController: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {

    func didChange(_ state: OIDAuthState) {
        appStateChanged()
    }

    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        logMessage("Received authorization error: \(error)")
    }
}

extension TokenViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedRange = NSMakeRange(0, textView.text.count)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        accessTokenTextView.endEditing(true)
        refreshTokenTextView.endEditing(true)
    }
}

//MARK: Helper Methods
extension TokenViewController {

    func saveAppState() {
        if let authState = self.authState {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: false)
                if let userDefaults = UserDefaults(suiteName: "group.net.openid.appauth.Example") {
                    userDefaults.set(data, forKey: kAppAuthExampleAuthStateKey)
                    userDefaults.synchronize()
                }
            } catch {
                self.logMessage("Unable to store auth state")
            }
        }
    }

    func loadAppState() {
        if let data = UserDefaults(suiteName: "group.net.openid.appauth.Example")?.object(forKey: kAppAuthExampleAuthStateKey) as? Data {
            do {
                let storedAuthState = try NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data)
                setAuthState(storedAuthState)
            } catch {
                self.logMessage("Unable to retrieve stored auth state")
            }
        }
    }

    func setAuthState(_ authState: OIDAuthState?) {
        if (self.authState == authState) {
            return
        }
        self.authState = authState
        self.authState?.stateChangeDelegate = self
        appStateChanged()
    }

    func updateUI() {

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {

                self.profileButton.isHidden = self.isBrowserSessionRevoked

                guard let authState = self.authState else {
                    self.tokenStackView.isHidden = true
                    self.accessTokenStackView.isHidden = true
                    self.refreshTokenTextView.isHidden = true
                    return
                }
                
                self.codeExchangeButton.isHidden = authState.lastTokenResponse != nil || self.isRefreshTokenRevoked || self.isAccessTokenRevoked
                self.refreshTokenButton.isHidden = authState.lastTokenResponse == nil || self.isRefreshTokenRevoked || self.isAccessTokenRevoked
                self.userinfoButton.isHidden = authState.lastTokenResponse == nil || self.isRefreshTokenRevoked || self.isAccessTokenRevoked

                if let accessToken = authState.lastTokenResponse?.accessToken {
                    self.accessTokenStackView.isHidden = false
                    self.accessTokenTextView.text = accessToken
                    self.accessTokenTitleLabel.text = self.isAccessTokenRevoked ? "Access Token Revoked:" : "Access Token:"
                } else {
                    self.accessTokenStackView.isHidden = true
                }

                if let refreshToken = authState.lastTokenResponse?.refreshToken {
                    self.refreshTokenStackView.isHidden = false
                    self.refreshTokenTextView.text = refreshToken
                    self.refreshTokenTitleLabel.text = self.isRefreshTokenRevoked ? "Refresh Token Revoked:" : "Refresh Token:"
                } else {
                    self.refreshTokenStackView.isHidden = true
                }
            }
        }
    }

    func appStateChanged() {
        saveAppState()
        updateUI()
    }

    func logMessage(_ message: String?) {

        guard let message = message else {
            return
        }

        DispatchQueue.main.async {

            // check if log was empty to enable clearing
            let isLogPreviouslyEmpty = self.logTextView.text.isEmpty

            print(message)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss"
            let dateString = dateFormatter.string(from: Date())

            // appends to output log
            let logText = "\(self.logTextView.text ?? "")\n\(dateString): \(message)"
            self.logTextView.text = logText

            let range = NSMakeRange(self.logTextView.text.count - 1, 0)
            self.logTextView.scrollRangeToVisible(range)

            if isLogPreviouslyEmpty {
                self.updateUI()
            }
        }
    }

    func displayLogoutAlert() {
        let logoutViewController = LogoutOptionsController()

        let logoutAlertController = UIAlertController(title: "Sign Out Options", message: nil, preferredStyle: .alert)
        logoutAlertController.setValue(logoutViewController, forKey: "contentViewController")

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            self.handleLogoutSelections(logoutViewController.selectedLogoutOptions)
        }

        logoutAlertController.addAction(cancelAction)
        logoutAlertController.addAction(submitAction)

        self.present(logoutAlertController, animated: true, completion: nil)
    }

    func handleLogoutSelections(_ logoutSelections: Set<LogoutType>) {

        let logoutGroup = DispatchGroup()

        if ((logoutSelections.contains(LogoutType.revokeTokens) || logoutSelections.contains(LogoutType.appSession)) && (!isAccessTokenRevoked || !isRefreshTokenRevoked)) {

            if let authState = authState, let lastTokenResponse = authState.lastTokenResponse, let accessToken = lastTokenResponse.accessToken, let refreshToken = lastTokenResponse.refreshToken {

                logoutGroup.enter()

                DispatchQueue.global().async(group: logoutGroup) {
                    self.revokeAccessToken(accessToken: accessToken) { complete, err in
                        if complete {
                            self.isAccessTokenRevoked = true
                            logoutGroup.leave()
                        }
                    }
                }

                logoutGroup.enter()

                DispatchQueue.global().async(group: logoutGroup) {
                    self.revokeRefreshToken(refreshToken: refreshToken) { complete, err in
                        if complete {
                            self.isRefreshTokenRevoked = true

                            if !logoutSelections.contains(LogoutType.browserSession) || !logoutSelections.contains(LogoutType.appSession) {
                                self.updateUI()
                            }

                            logoutGroup.leave()
                        }
                    }
                }
            }
        }

        if (logoutSelections.contains(LogoutType.browserSession)) {

            logoutGroup.enter()

            DispatchQueue.global().async(group: logoutGroup) {
                self.endBrowserSession { complete, err in
                    if complete {
                        self.isBrowserSessionRevoked = true

                        if !logoutSelections.contains(LogoutType.appSession) {
                            self.updateUI()
                        }

                        logoutGroup.leave()
                    }
                }
            }
        }

        if (logoutSelections.contains(LogoutType.appSession)) {
            logoutGroup.notify(queue: .global()) {
                self.endAppSession()
            }
        }
    }
}
