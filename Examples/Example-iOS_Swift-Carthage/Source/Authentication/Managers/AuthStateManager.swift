//
//  AuthStateManager.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit
import AppAuth

enum State: String {
    case active = "Active"
    case inactive = "Inactive"
}

enum TokenType: String {
    case accessToken = "Access Token"
    case refreshToken = "Refresh Token"
}

protocol AuthStateManagerDelegate: AnyObject {
    func stateChanged()
    func errorOccured(_ error: AuthError)
}

// MARK: AuthStateManagerProtocol
protocol AuthStateManagerProtocol {
    var authState: OIDAuthState? { get }
    var browserState: State { get }
    var authorizationState: State { get }
    var accessToken: String? { get }
    var accessTokenState: State { get }
    var refreshToken: String? { get }
    var refreshTokenState: State { get }
    var lastTokenResponse: OIDTokenResponse? { get }
    var tokenRefreshRequest: OIDTokenRequest? { get }
    var lastAuthorizationResponse: OIDAuthorizationResponse? { get }
    var tokenExchangeRequest: OIDTokenRequest? { get }
    func setTokenState(_ tokenType: TokenType, state: State) -> Void
    func loadAuthState() -> Void
    func setAuthState(_ authState: OIDAuthState?) -> Void
    func updateWithTokenResponse(_ response: OIDTokenResponse?, error: Error?) -> Void
    func loadBrowserState() -> Void
    func setBrowserState(_ state: State) -> Void
    func getStateData() -> String
}

class AuthStateManager: NSObject, AuthStateManagerProtocol {
    
    private(set) var userDefaults: UserDefaultsProtocol
    private(set) var authConfig: AuthConfigProtocol
    private(set) var authState: OIDAuthState?
    private(set) var browserState: State = .inactive
    
    required init(_ authConfig: AuthConfigProtocol,
                  userDefaults: UserDefaultsProtocol = UserDefaults.standard) {
        
        self.authConfig = authConfig
        self.userDefaults = userDefaults
        
        super.init()
        
        loadStoredState()
    }
    
    var authorizationState: State {
        switch authState?.isAuthorized ?? false {
        case true: return .active
        case false: return .inactive
        }
    }
    
    private(set) var accessTokenState: State = .inactive
    private(set) var accessToken: String? {
        get {
            authState?.lastTokenResponse?.accessToken
        }
        set {
            if let _ = newValue {
                accessTokenState = .active
            } else {
                accessTokenState = .inactive
            }
        }
    }
    
    private(set) var refreshTokenState: State = .inactive
    private(set) var refreshToken: String? {
        get {
            authState?.refreshToken
        }
        set {
            if let _ = newValue {
                refreshTokenState = .active
            } else {
                refreshTokenState = .inactive
            }
        }
    }
    
    var lastTokenResponse: OIDTokenResponse? {
        authState?.lastTokenResponse
    }
    
    var tokenRefreshRequest: OIDTokenRequest? {
        authState?.tokenRefreshRequest()
    }
    
    var lastAuthorizationResponse: OIDAuthorizationResponse? {
        authState?.lastAuthorizationResponse
    }
    
    var tokenExchangeRequest: OIDTokenRequest? {
        lastAuthorizationResponse?.tokenExchangeRequest()
    }
    
    func setTokenState(_ tokenType: TokenType, state: State) {
        switch tokenType {
        case .accessToken:
            accessTokenState = state
        case .refreshToken:
            refreshTokenState = state
        }
    }
}

//=============================================
// MARK: AuthState Storage Management
//=============================================

extension AuthStateManager {
    
    private func loadStoredState() {
        loadAuthState()
        loadBrowserState()
    }
    
    func loadAuthState() {
        
        guard let savedAuthStateData = userDefaults.data(forKey: authConfig.authStateStorageKey) else {
            print("Authorization state failed to load.")
            return
        }
        
        if let savedAuthState = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedAuthStateData) as? OIDAuthState {
            
            print("Authorization state has been loaded.")
            
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
        
        if let authState = authState,
           let authStateData = try? NSKeyedArchiver.archivedData(withRootObject: authState,
                                                                 requiringSecureCoding: false)
        {
            userDefaults.set(authStateData, forKey: authConfig.authStateStorageKey)
        }
        
        accessToken = authState?.lastTokenResponse?.accessToken
        refreshToken = authState?.refreshToken
        
        print(getStateData())
        print("Authorization state has been saved.")
    }
    
    func updateWithTokenResponse(_ response: OIDTokenResponse?, error: Error?) {
        authState?.update(with: response, error: error)
        
        if let response = response {
            setTokenState(.accessToken, state: response.accessToken == nil ? .inactive : .active)
            setTokenState(.refreshToken, state: response.refreshToken == nil ? .inactive : .active)
        } else {
            setTokenState(.accessToken, state: .inactive)
            setTokenState(.refreshToken, state: .inactive)
        }
    }
    
    func loadBrowserState() {
        let savedBrowserStateBool = userDefaults.bool(forKey: authConfig.browserStateStorageKey)
        let savedbrowserState: State = savedBrowserStateBool ? .active : .inactive
        setBrowserState(savedbrowserState)
        print("\(browserState.rawValue) browser state has been loaded.")
    }
    
    func setBrowserState(_ state: State) {
        if browserState != state {
            browserState = state
            
            saveBrowserState()
        }
    }
    
    private func saveBrowserState() {
        let browserStateBool = browserState == .active
        userDefaults.set(browserStateBool, forKey: authConfig.browserStateStorageKey)
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
