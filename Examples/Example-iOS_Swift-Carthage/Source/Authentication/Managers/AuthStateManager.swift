//
//  AuthStateManager.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit
import AppAuth

enum BrowserState: String {
    case active = "Active"
    case inactive = "Inactive"
}

protocol AuthStateManagerDelegate: AnyObject {
    func stateChanged()
    func errorOccured(_ error: AuthError)
}

protocol AuthStateManagerProtocol {
    var authState: OIDAuthState? { get }
    var browserState: BrowserState { get }
    var isAuthStateAuthorized: Bool { get }
    var discoveryConfig: OIDServiceConfiguration? { get }
    var accessToken: String? { get }
    var refreshToken: String? { get }
    var lastTokenResponse: OIDTokenResponse? { get }
    var authorizationCode: String? { get }
    
    func loadAuthState()
    func setAuthState(_ authState: OIDAuthState?)
    func updateWithTokenResponse(_ response: OIDTokenResponse?, error: Error?)
    func loadBrowserState()
    func setBrowserState(_ state: BrowserState)
    func getStateData() -> String
}

protocol UserDefaultsProtocol {
    func data(forKey defaultName: String) -> Data?
    func bool(forKey defaultName: String) -> Bool
    func set(_ value: Any?, forKey defaultName: String)
    func set(_ value: Bool, forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProtocol { }

class AuthStateManager: NSObject, AuthStateManagerProtocol {
    
    private var userDefaults: UserDefaultsProtocol = UserDefaults.standard
    
    var authState: OIDAuthState?
    var browserState: BrowserState = .inactive
    
    var isAuthStateAuthorized: Bool {
        return authState?.isAuthorized ?? false
    }
    
    var discoveryConfig: OIDServiceConfiguration? {
        return authState?.lastAuthorizationResponse.request.configuration
    }
    
    var accessToken: String? {
        return authState?.lastTokenResponse?.accessToken
    }
    
    var refreshToken: String? {
        return authState?.refreshToken
    }
    
    var lastTokenResponse: OIDTokenResponse? {
        return authState?.lastTokenResponse
    }
    
    var authorizationCode: String? {
        return authState?.lastAuthorizationResponse.authorizationCode
    }
    
    var tokenRefreshRequest: OIDTokenRequest? {
        return authState?.tokenRefreshRequest()
    }
}

//=============================================
// MARK: AuthState Storage Management
//=============================================

extension AuthStateManager {
    
    func loadAuthState() {
        
        guard let savedAuthStateData = userDefaults.data(forKey: AuthConfig.authStateStorageKey) else {
            print("Authorization state failed to load.")
            return
        }
        
        let savedAuthState = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedAuthStateData) as? OIDAuthState
        
        if let savedAuthState = savedAuthState {
            print("Authorization state has been loaded.")
            
            savedAuthState.setNeedsTokenRefresh()
            setAuthState(savedAuthState)
        }
    }
    
    func setAuthState(_ authState: OIDAuthState?) {
        if self.authState != authState {
            self.authState = authState
            
            authState?.stateChangeDelegate = self
            authState?.errorDelegate = self
            
            saveAuthState()
        }
    }
    
    private func saveAuthState() {
        var authStateData: Data? = nil
        
        if let authState = authState {
            authStateData = try? NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: false)
        }
        
        userDefaults.set(authStateData, forKey: AuthConfig.authStateStorageKey)
        
        print(getStateData())
        print("Authorization state has been saved.")
    }
    
    
    func updateWithTokenResponse(_ response: OIDTokenResponse?, error: Error?) {
        authState?.update(with: response, error: error)
    }
    
    func loadBrowserState() {
        let savedBrowserStateBool = userDefaults.bool(forKey: AuthConfig.browserStateStorageKey)
        let savedbrowserState: BrowserState = savedBrowserStateBool ? .active : .inactive
        setBrowserState(savedbrowserState)
        print("\(browserState.rawValue) browser state has been loaded.")
    }
    
    func setBrowserState(_ state: BrowserState) {
        if browserState != state {
            browserState = state
            
            saveBrowserState()
        }
    }
    
    private func saveBrowserState() {
        let browserStateBool = browserState == .active
        userDefaults.set(browserStateBool, forKey: AuthConfig.browserStateStorageKey)
        print("\(browserState.rawValue) browser state has been saved.")
    }
    
    func getStateData() -> String {
        var stateData = ""
        
        stateData += "Current authorization state:\n"
        stateData += "Access token: \(lastTokenResponse?.accessToken ?? "none")\n"
        stateData += "Refresh token: \(lastTokenResponse?.refreshToken ?? "none")\n"
        stateData += "Expiration date: \(authState?.lastTokenResponse?.accessTokenExpirationDate?.debugDescription ?? "none")\n"
        stateData += "Browser session state: \(browserState.rawValue)\n"
        
        return stateData
    }
}

//=============================================
// MARK: OIDAuthState delegates
//=============================================

extension AuthStateManager: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    /*
     * Responds to authorization state changes in the AppAuth library.
     */
    func didChange(_ state: OIDAuthState) {
        print("Authorization state change event.")
        
        saveAuthState()
    }
    
    /*
     * Responds to errors occurring in the AppAuth library.
     */
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        print("Received authorization error: \(error)")
    }
}
