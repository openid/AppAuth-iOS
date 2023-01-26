//
//  AuthStateManager.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit
import AppAuth

protocol AuthStateDelegate: AnyObject {
    func authStateChanged()
    func authStateErrorOccured(_ error: AuthError)
}

protocol AuthStateManagerProtocol {
    
    func loadAuthState()
    func setAuthState(_ authState: OIDAuthState?)
    func printStateData()
    
    var isAppSessionActive: Bool { get }
    var isBrowserSessionActive: Bool { get set }
    var isCodeExchangeRequired: Bool { get }
    var isAccessTokenActive: Bool { get set }
    var isRefreshTokenActive: Bool { get set }
    var lastAccessTokenResponse: String? { get set }
    var lastRefreshTokenResponse: String? { get set }
}

protocol UserDefaultsProtocol {
    func data(forKey defaultName: String) -> Data?
    func bool(forKey defaultName: String) -> Bool
    func set(_ value: Any?, forKey defaultName: String)
    func set(_ value: Bool, forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProtocol { }

class AuthStateManager: NSObject, AuthStateManagerProtocol {
    
    weak var delegate: AuthStateDelegate?
    var userDefaults: UserDefaultsProtocol = UserDefaults.standard
    
    var authState: OIDAuthState? {
        didSet {
            lastAccessTokenResponse = authState?.lastTokenResponse?.accessToken
            lastRefreshTokenResponse = authState?.lastTokenResponse?.refreshToken
            
            delegate?.authStateChanged()
        }
    }
    
    /*
     * Return current authorization state for the application
     */
    var isAppSessionActive: Bool {
        return authState?.isAuthorized ?? false || isBrowserSessionActive
    }
    
    var isBrowserSessionActive: Bool = false {
        didSet {
            delegate?.authStateChanged()
        }
    }
    
    var isAuthStateActive: Bool {
        return authState?.isAuthorized ?? false
    }
    
    var isAccessTokenActive = false
    var isRefreshTokenActive = false
    
    var lastAccessTokenResponse: String? = nil {
        didSet {
            isAccessTokenActive = lastAccessTokenResponse != nil
        }
    }
    var lastRefreshTokenResponse: String? = nil {
        didSet {
            isRefreshTokenActive = lastRefreshTokenResponse != nil
        }
    }
    
    var isCodeExchangeRequired: Bool {
        return authState?.lastAuthorizationResponse.authorizationCode != nil &&
                authState?.lastTokenResponse == nil
    }
    
    func setAuthState(_ authState: OIDAuthState?) {
        if self.authState != authState {
            self.authState = authState
            
            authState?.stateChangeDelegate = self
            
            stateChanged()
        }
    }
    
    func loadAuthState() {
        isBrowserSessionActive = userDefaults.bool(forKey: AuthConfig.browserStateStorageKey)
        
        guard let authStateData = userDefaults.data(forKey: AuthConfig.authStateStorageKey) else {
            print("Authorization state failed to load.")
            return
        }
        
        let savedAuthState = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(authStateData) as? OIDAuthState
        
        if let authState = savedAuthState {
            print("Authorization state has been loaded.")
            
            authState.setNeedsTokenRefresh()
            setAuthState(authState)
        }
    }
    
    func saveAuthState() {
        var authStateData: Data? = nil
        
        if let authState = authState {
            authStateData = try? NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: false)
        }
        
        userDefaults.set(isBrowserSessionActive, forKey: AuthConfig.browserStateStorageKey)
        userDefaults.set(authStateData, forKey: AuthConfig.authStateStorageKey)
        
        print("Authorization state has been saved.")
    }
    
    private func stateChanged() {
        saveAuthState()
    }
    
    func printStateData() {
        print("Current authorization state: ")
        
        print("Access token: \(authState?.lastAuthorizationResponse.accessToken ?? "none")")
        
        print("Refresh token: \(authState?.refreshToken ?? "none")")
        
        print("Expiration date: \(String(describing: authState?.lastTokenResponse?.accessTokenExpirationDate))")
        
        print("Current session state: ")
        
        print("App session active: \(isAppSessionActive)")
        
        print("Browser session active: \(isBrowserSessionActive)")
    }
}

//=============================================
// MARK: OIDAuthState delegates
//=============================================

extension AuthStateManager: OIDAuthStateChangeDelegate {
    /*
     * Responds to authorization state changes in the AppAuth library.
     */
    func didChange(_ state: OIDAuthState) {
        print("Authorization state change event.")
        
        stateChanged()
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        print("Received authorization error: \(error)")
        
        let authError = AuthError(.authStateError)
        delegate?.authStateErrorOccured(authError)
    }
}
