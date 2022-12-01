//
//  AppAuthExampleViewController.swift
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

typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void

typealias PostDiscoveryCallback = (_ configuration: OIDServiceConfiguration?, _ clientId: String, _ clientSecret: String?) -> Void

/**
 The OIDC issuer from which the configuration will be discovered.
 */
let kIssuer: String = "https://api.multi.dev.or.janrain.com/00000000-0000-0000-0000-000000000000/login"

/**
 The OAuth client ID.

 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 Set to nil to use dynamic registration with this example.
 */
let kClientID: String? = "cec9a504-a0ab-4b92-879b-711482a3f69b"

/**
 The OAuth redirect URI for the client @c kClientID.

 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kRedirectURI: String = "net.openid.appauthdemo://oauth2redirect"

/**
 The OAuth prompt specification.
 
 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kPrompt: String? = nil

/**
 The OAuth claims specification.
 
 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kClaims: String? = nil

/**
 The OAuth ACR claims specification.
 
 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kAcrValues: String? = "urn:akamai-ic:nist:800-63-3:aal:1"

/**
 The OAuth scope specification.
 
 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kScopes: [String] = [OIDScopeOpenID, OIDScopeProfile]

/**
 The additional paramaters configuration
 
 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
var kAdditionalParamaters: [String : String] = [:]

/**
 NSCoding key for the authState property.
 */
let kAppAuthExampleAuthStateKey: String = "authState"

class AppAuthExampleViewController: UIViewController {

    @IBOutlet private weak var authButton: UIButton!
    @IBOutlet weak var authTypeSegementedControl: UISegmentedControl!
    @IBOutlet private weak var authActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var logTextView: UITextView!

    private var authState: OIDAuthState?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        validateOAuthConfiguration()
        configureAdditionalParameters()

        loadAppState()
    }
}

extension AppAuthExampleViewController {

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
    }
}

//MARK: IBActions
extension AppAuthExampleViewController {

    @IBAction func authorizeUser(_ sender: UIButton) {

        if authTypeSegementedControl.selectedSegmentIndex == 0 {
            authWithAutoCodeExchange()
        } else {
            authNoCodeExchange()
        }

        updateUI(isLoading: true)
    }

    func authWithAutoCodeExchange() {

        // discovers endpoints
        discoverConfig { configuration, clientId, clientSecret in

            guard let configuration = configuration else {
                self.logMessage("Configuration retrieval failed.")
                self.updateUI(isLoading: false)
                return
            }

            self.logMessage("Got configuration: \(configuration)")

            if let clientId = kClientID {
                self.doAuthWithAutoCodeExchange(configuration: configuration, clientID: clientId, clientSecret: nil)
            } else {
                self.doClientRegistration(configuration: configuration) { configuration, response in

                    guard let configuration = configuration, let clientID = response?.clientID else {
                        self.logMessage("Error retrieving configuration OR clientID")
                        self.updateUI(isLoading: false)
                        return
                    }

                    self.doAuthWithAutoCodeExchange(configuration: configuration,
                                                    clientID: clientID,
                                                    clientSecret: response?.clientSecret)
                }
            }
        }
    }

    func authNoCodeExchange() {

        // discovers endpoints
        discoverConfig { configuration, clientId, clientSecret  in

            guard let configuration = configuration else {
                self.logMessage("Configuration retrieval failed.")
                self.updateUI(isLoading: false)
                return
            }

            self.logMessage("Got configuration: \(configuration)")

            if let clientId = kClientID {

                self.doAuthWithoutCodeExchange(configuration: configuration, clientID: clientId, clientSecret: nil)

            } else {

                self.doClientRegistration(configuration: configuration) { configuration, response in

                    guard let configuration = configuration, let response = response else {
                        self.updateUI(isLoading: false)
                        return
                    }

                    self.doAuthWithoutCodeExchange(configuration: configuration,
                                                   clientID: response.clientID,
                                                   clientSecret: response.clientSecret)
                }
            }
        }
    }

    @IBAction func clearLog(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.logTextView.text = ""
        }
    }
}

//MARK: AppAuth Methods
extension AppAuthExampleViewController {

    func discoverConfig(callback: @escaping PostDiscoveryCallback) {

        guard let issuer = URL(string: kIssuer) else {
            logMessage("Error creating URL for : \(kIssuer)")
            updateUI(isLoading: false)
            return
        }

        logMessage("Fetching configuration for issuer: \(issuer)")

        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in

            if let error = error  {
                self.logMessage("Error retrieving discovery document: \(error.localizedDescription)")
                self.updateUI(isLoading: false)
                return
            }

            guard let configuration = configuration else {
                self.logMessage("Error retrieving discovery document. Error & Configuration both are NIL!")
                self.updateUI(isLoading: false)
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
            updateUI(isLoading: false)
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
        self.logMessage("Initiating registration request")

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
            updateUI(isLoading: false)
            return
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            logMessage("Error accessing AppDelegate")
            updateUI(isLoading: false)
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
                self.setAuthState(authState)
                self.logMessage("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")

                UIApplication.setRootView(TokenViewController.instantiate(from: .Main))
            } else {
                self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
    }

    func doAuthWithoutCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {

        guard let redirectURI = URL(string: kRedirectURI) else {
            logMessage("Error creating URL for : \(kRedirectURI)")
            updateUI(isLoading: false)
            return
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            logMessage("Error accessing AppDelegate")
            updateUI(isLoading: false)
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

        appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: self) { (response, error) in

            if let response = response {
                let authState = OIDAuthState(authorizationResponse: response)
                self.setAuthState(authState)
                self.logMessage("Authorization response with code: \(response.authorizationCode ?? "DEFAULT_CODE")")
                // could just call [self tokenExchange:nil] directly, but will let the user initiate it.
                UIApplication.setRootView(TokenViewController.instantiate(from: .Main))
            } else {
                self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
    }
}

//MARK: OIDAuthState Delegate
extension AppAuthExampleViewController: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {

    func didChange(_ state: OIDAuthState) {
        appStateChanged()
    }

    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        logMessage("Received authorization error: \(error)")
    }
}

//MARK: Helper Methods
extension AppAuthExampleViewController {

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
        updateUI(isLoading: false)

        if (self.authState == authState) {
            return
        }
        
        self.authState = authState
        self.authState?.stateChangeDelegate = self
        appStateChanged()
    }

    func appStateChanged() {
        saveAppState()
    }

    func updateUI(isLoading: Bool) {

        if isLoading {
            authActivityIndicator.startAnimating()
            UIView.animate(withDuration: 0.25, animations: {
                self.authButton.alpha = 0.5
            })

        } else {
            authActivityIndicator.stopAnimating()
            UIView.animate(withDuration: 0.25, animations: {
                self.authButton.alpha = 1.0
            })
        }

        authButton.isEnabled = !isLoading
        authTypeSegementedControl.isEnabled = !isLoading
    }

    func logMessage(_ message: String?) {

        guard let message = message else {
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        let dateString = dateFormatter.string(from: Date())

        // appends to output log
        DispatchQueue.main.async {
            let logText = "\(self.logTextView.text ?? "")\n\(dateString): \(message)"
            self.logTextView.text = logText
            
            let range = NSMakeRange(self.logTextView.text.count - 1, 0)
            self.logTextView.scrollRangeToVisible(range)
        }
    }
}
