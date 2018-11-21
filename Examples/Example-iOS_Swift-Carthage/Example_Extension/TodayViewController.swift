//
//  TodayViewController.swift
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

import UIKit
import NotificationCenter
import AppAuthCore

/**
 NSCoding key for the authState property.
 */
let kAppAuthExampleAuthStateKey: String = "authState";

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet private weak var logTextView: UITextView!
    
    private var authState: OIDAuthState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            self.preferredContentSize = CGSize(width: 0, height: 400.0)
        }
        
        self.loadState()
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: maxSize.width, height: 400.0)
        } else if activeDisplayMode == .compact {
            preferredContentSize = maxSize
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func userinfo(_ sender: UIButton) {
        
        guard let userinfoEndpoint = self.authState?.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint else {
            self.logMessage("Userinfo endpoint not declared in discovery document")
            return
        }
        
        self.logMessage("Performing userinfo request")
        
        let currentAccessToken: String? = self.authState?.lastTokenResponse?.accessToken
        
        self.authState?.performAction() { (accessToken, idTOken, error) in
            
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
    
    @IBAction func clearLogTextView(_ sender: UIButton) {
        self.logTextView.text = ""
    }
}

//MARK: OIDAuthState Delegate
extension TodayViewController: OIDAuthStateChangeDelegate {
    
    func didChange(_ state: OIDAuthState) {
        self.stateChanged()
    }
}

//MARK: Helper Methods
extension TodayViewController {
    
    func saveState() {
        
        var data: Data? = nil
        
        if let authState = self.authState {
            data = NSKeyedArchiver.archivedData(withRootObject: authState)
        }
        
        if let userDefaults = UserDefaults(suiteName: "group.net.openid.appauth.Example") {
            userDefaults.set(data, forKey: kAppAuthExampleAuthStateKey)
            userDefaults.synchronize()
        }
    }
    
    func loadState() {
        guard let data = UserDefaults(suiteName: "group.net.openid.appauth.Example")?.object(forKey: kAppAuthExampleAuthStateKey) as? Data else {
            return
        }
        
        if let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
            self.setAuthState(authState)
        }
    }
    
    func setAuthState(_ authState: OIDAuthState?) {
        if (self.authState == authState) {
            return;
        }
        self.authState = authState;
        self.authState?.stateChangeDelegate = self;
        self.stateChanged()
    }
    
    func stateChanged() {
        self.saveState()
    }
    
    func logMessage(_ message: String?) {
        
        guard let message = message else {
            return
        }
        
        print(message);
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss";
        let dateString = dateFormatter.string(from: Date())
        
        // appends to output log
        DispatchQueue.main.async {
            let logText = "\(self.logTextView.text ?? "")\n\(dateString): \(message)"
            self.logTextView.text = logText
        }
    }
}
