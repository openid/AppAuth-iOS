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

/**
 The OIDC issuer from which the configuration will be discovered.
*/
let kIssuer: String = "https://api.multi.dev.or.janrain.com/00000000-0000-0000-0000-000000000000/login";

/**
 The OAuth client ID.

 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 Set to nil to use dynamic registration with this example.
*/
let kClientID: String? = "cec9a504-a0ab-4b92-879b-711482a3f69b";

/**
 The OAuth redirect URI for the client @c kClientID.

 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
*/
let kRedirectURI: String = "net.openid.appauthdemo://oauth2redirect";

/**
 The OAuth logout URI for the client @c kClientID.
 
 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kLogoutURI: String? = "https://api.multi.dev.or.janrain.com/00000000-0000-0000-0000-000000000000/auth-ui/logout";

/**
 The Profile Management URI for the client @c kClientID.
 
 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kProfileURI: String? = "https://api.multi.dev.or.janrain.com/00000000-0000-0000-0000-000000000000/auth-ui/profile";

/**
 The OAuth prompt specification.
 
 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kPrompt: String? = nil;

/**
 The OAuth claims specification.
 
 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kClaims: String? = nil;

/**
 The OAuth ACR claims specification.
 
 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kAcrValues: String? = "urn:akamai-ic:nist:800-63-3:aal:1";

/**
 The OAuth scope specification.
 
 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kScopes: [String] = [OIDScopeOpenID, OIDScopeProfile];

/**
 The additional paramaters configuration
 
 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
var kAdditionalParamaters: [String : String] = [:];

/**
 NSCoding key for the authState property.
*/
let kAppAuthExampleAuthStateKey: String = "authState";

/**
 NSCoding key for the browserState property.
 */
let kAppAuthExampleBrowserStateKey: String = "browserState";

class AppAuthExampleViewController: UIViewController {

    @IBOutlet private weak var authAutoButton: UIButton!
    @IBOutlet private weak var authManual: UIButton!
    @IBOutlet private weak var codeExchangeButton: UIButton!
    @IBOutlet private weak var userinfoButton: UIButton!
    @IBOutlet private weak var logTextView: UITextView!
    @IBOutlet private weak var trashButton: UIBarButtonItem!

    private var authState: OIDAuthState?
    private var browserStateActive = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.validateOAuthConfiguration()
        self.configureAdditionalParameters()

        self.loadAppState()
        self.loadBrowserState()
        self.updateUI()
    }
}

extension AppAuthExampleViewController {

    func validateOAuthConfiguration() {

        // The example needs to be configured with your own client details.
        // See: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md

        assert(kIssuer != "https://issuer.example.com",
                "Update kIssuer with your own issuer.\n" +
                "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md");

        assert(kClientID != "YOUR_CLIENT_ID",
                "Update kClientID with your own client ID.\n" +
                "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md");

        assert(kRedirectURI != "com.example.app:/oauth2redirect/example-provider",
                "Update kRedirectURI with your own redirect URI.\n" +
                "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md");

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
}

//MARK: IBActions
extension AppAuthExampleViewController {

    @IBAction func authWithAutoCodeExchange(_ sender: UIButton) {

        guard let issuer = URL(string: kIssuer) else {
            self.logMessage("Error creating URL for : \(kIssuer)")
            return
        }

        self.logMessage("Fetching configuration for issuer: \(issuer)")

        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in

            guard let config = configuration else {
                self.logMessage("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
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

    @IBAction func authNoCodeExchange(_ sender: UIButton) {

        guard let issuer = URL(string: kIssuer) else {
            self.logMessage("Error creating URL for : \(kIssuer)")
            return
        }

        self.logMessage("Fetching configuration for issuer: \(issuer)")

        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in

            if let error = error  {
                self.logMessage("Error retrieving discovery document: \(error.localizedDescription)")
                return
            }

            guard let configuration = configuration else {
                self.logMessage("Error retrieving discovery document. Error & Configuration both are NIL!")
                return
            }

            self.logMessage("Got configuration: \(configuration)")

            if let clientId = kClientID {

                self.doAuthWithoutCodeExchange(configuration: configuration, clientID: clientId, clientSecret: nil)

            } else {

                self.doClientRegistration(configuration: configuration) { configuration, response in

                    guard let configuration = configuration, let response = response else {
                        return
                    }

                    self.doAuthWithoutCodeExchange(configuration: configuration,
                                                   clientID: response.clientID,
                                                   clientSecret: response.clientSecret)
                }
            }
        }
    }

    @IBAction func codeExchange(_ sender: UIButton) {

        guard let tokenExchangeRequest = self.authState?.lastAuthorizationResponse.tokenExchangeRequest() else {
            self.logMessage("Error creating authorization code exchange request")
            return
        }

        self.logMessage("Performing authorization code exchange with request \(tokenExchangeRequest)")

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

        guard let userinfoEndpoint = self.authState?.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint else {
            self.logMessage("Userinfo endpoint not declared in discovery document")
            return
        }

        self.logMessage("Performing userinfo request")

        let currentAccessToken: String? = self.authState?.lastTokenResponse?.accessToken

        self.authState?.performAction() { (accessToken, idToken, error) in

            if error != nil  {
                self.logMessage("Error fetching fresh tokens: \(error?.localizedDescription ?? "ERROR")")
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

    @IBAction func profileManagement(_ sender: UIButton) {

        guard let issuer = URL(string: kIssuer) else {
            self.logMessage("Error creating URL for : \(kIssuer)")
            return
        }

        self.logMessage("Fetching configuration for issuer: \(issuer)")

        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in

            guard let config = configuration else {
                self.logMessage("Error retrieving discovery document: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
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

    @IBAction func trashClicked(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: UIAlertControllerStyle.actionSheet)

        if authState != nil {
            let clearAuthAction = UIAlertAction(title: "Clear App Session", style: .destructive) { (_: UIAlertAction) in
                self.setAuthState(nil)
            }
            alert.addAction(clearAuthAction)
        }
        
        if browserStateActive {
            let clearBrowserAction = UIAlertAction(title: "Clear Browser Session", style: .destructive) { (_: UIAlertAction) in
                self.endBrowserSession()
            }
            alert.addAction(clearBrowserAction)
        }
        
        if logTextView.hasText{
            let clearLogs = UIAlertAction(title: "Clear Logs", style: .default) { (_: UIAlertAction) in
                DispatchQueue.main.async {
                    self.logTextView.text = ""
                    self.updateUI()
                }
            }
            alert.addAction(clearLogs)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
}

//MARK: AppAuth Methods
extension AppAuthExampleViewController {

    func doClientRegistration(configuration: OIDServiceConfiguration, callback: @escaping PostRegistrationCallback) {

        guard let redirectURI = URL(string: kRedirectURI) else {
            self.logMessage("Error creating URL for : \(kRedirectURI)")
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
            self.logMessage("Error creating URL for : \(kRedirectURI)")
            return
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.logMessage("Error accessing AppDelegate")
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
                self.setBrowserStateActive(true)
                self.logMessage("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
            } else {
                self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
    }

    func doAuthWithoutCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {

        guard let redirectURI = URL(string: kRedirectURI) else {
            self.logMessage("Error creating URL for : \(kRedirectURI)")
            return
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.logMessage("Error accessing AppDelegate")
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
                self.setBrowserStateActive(true)
                self.logMessage("Authorization response with code: \(response.authorizationCode ?? "DEFAULT_CODE")")
                // could just call [self tokenExchange:nil] directly, but will let the user initiate it.
            } else {
                self.logMessage("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
            }
        }
    }

    func loadProfileManagement(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
        
        guard let redirectURI = URL(string: kRedirectURI) else {
            self.logMessage("Error creating URL for : \(kRedirectURI)")
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.logMessage("Error accessing AppDelegate")
            return
        }
        
        guard let profileUriString = kProfileURI,
              !profileUriString.isEmpty,
              let profileUri = URL(string: profileUriString)
        else {
            self.logMessage("Error accessing kProfileUri")
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
            self.logMessage("Error retrieving user agent")
            return
        }
        
        appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(request, externalUserAgent: userAgent) { (response, error) in
            
            if let logoutResponse = response {
                self.setBrowserStateActive(false)
                self.logMessage("Got profile management response: \(logoutResponse)")
            }  else {
                self.logMessage("profile management error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
            }
        }
    }
    
    func endBrowserSession() {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.logMessage("Error accessing AppDelegate")
            return
        }
        
        guard let issuer = URL(string: kIssuer) else {
            self.logMessage("Error creating URL for : \(kIssuer)")
            return
        }

        guard let redirectURI = URL(string: kRedirectURI) else {
          self.logMessage("Error creating URL for : \(kRedirectURI)")
          return
        }
        
        guard let clientId = kClientID else {
            self.logMessage("Error accessing clientId")
            return
        }
        
        guard let logoutUriString = kLogoutURI,
              !logoutUriString.isEmpty,
              let logoutUri = URL(string: logoutUriString)
        else {
            self.logMessage("Error accessing kLogoutUri")
            return
        }
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            
            if let error = error  {
                self.logMessage("Error retrieving discovery document: \(error.localizedDescription)")
                return
            }
            
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
            
            // opens the browser to clear auth sessionendSessionRequest  OIDEndSessionRequest  0x0000600000807930
            appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(endSessionRequest, externalUserAgent: userAgent) { (response, error) in
                if let logoutResponse = response {
                    self.setBrowserStateActive(false)
                    self.logMessage("Got logout response: \(logoutResponse)")
                }  else {
                    self.logMessage("Logout error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                }
            }
        }
    }
}

//MARK: OIDAuthState Delegate
extension AppAuthExampleViewController: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {

    func didChange(_ state: OIDAuthState) {
        self.appStateChanged()
    }

    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        self.logMessage("Received authorization error: \(error)")
    }
}

//MARK: Helper Methods
extension AppAuthExampleViewController {

    func saveAppState() {

        var data: Data? = nil

        if let authState = self.authState {
            data = NSKeyedArchiver.archivedData(withRootObject: authState)
        }
        
        if let userDefaults = UserDefaults(suiteName: "group.net.openid.appauth.Example") {
            userDefaults.set(data, forKey: kAppAuthExampleAuthStateKey)
            userDefaults.synchronize()
        }
    }
    
    func saveBrowserState() {

        if let userDefaults = UserDefaults(suiteName: "group.net.openid.appauth.Example") {
            userDefaults.set(browserStateActive, forKey: kAppAuthExampleBrowserStateKey)
            userDefaults.synchronize()
        }
    }

    func loadAppState() {
        if let data = UserDefaults(suiteName: "group.net.openid.appauth.Example")?.object(forKey: kAppAuthExampleAuthStateKey) as? Data,
           let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
            self.setAuthState(authState)
        }
    }
    
    func loadBrowserState() {
        if let browserData = UserDefaults(suiteName: "group.net.openid.appauth.Example")?.bool(forKey: kAppAuthExampleBrowserStateKey) {
            self.setBrowserStateActive(browserData)
        }
    }

    func setAuthState(_ authState: OIDAuthState?) {
        if (self.authState == authState) {
            return;
        }
        self.authState = authState;
        self.authState?.stateChangeDelegate = self;
        self.appStateChanged()
    }
    
    func setBrowserStateActive(_ browserState: Bool) {
        if (self.browserStateActive == browserState) {
            return;
        }
        self.browserStateActive = browserState;
        self.browserStateChanged()
    }

    func updateUI() {

        self.codeExchangeButton.isEnabled = self.authState?.lastAuthorizationResponse.authorizationCode != nil && !((self.authState?.lastTokenResponse) != nil)

        if let authState = self.authState {
            self.authAutoButton.setTitle("1. Re-Auth", for: .normal)
            self.authManual.setTitle("1(A) Re-Auth", for: .normal)
            self.userinfoButton.isEnabled = authState.isAuthorized ? true : false
        } else {
            self.authAutoButton.setTitle("1. Auto", for: .normal)
            self.authManual.setTitle("1(A) Manual", for: .normal)
            self.userinfoButton.isEnabled = false
        }
        
        if self.browserStateActive ||
            self.authState != nil ||
            self.logTextView.hasText
        {
            self.trashButton.isEnabled = true
        } else {
            self.trashButton.isEnabled = false
        }
    }

    func appStateChanged() {
        self.saveAppState()
        self.updateUI()
    }
    
    func browserStateChanged() {
        self.saveBrowserState()
        self.updateUI()
    }

    func logMessage(_ message: String?) {

        guard let message = message else {
            return
        }
        
        // check if log was empty to enable clearing
        let isLogPreviouslyEmpty = logTextView.text.isEmpty

        print(message);

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss";
        let dateString = dateFormatter.string(from: Date())

        // appends to output log
        DispatchQueue.main.async {
            let logText = "\(self.logTextView.text ?? "")\n\(dateString): \(message)"
            self.logTextView.text = logText
            
            let range = NSMakeRange(self.logTextView.text.count - 1, 0)
            self.logTextView.scrollRangeToVisible(range)
            
            if isLogPreviouslyEmpty {
                self.updateUI()
            }
        }
    }
}
