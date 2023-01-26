//
//  DashboardViewModel.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

protocol DashboardViewModelCoordinatorDelegate: BaseViewModelCoordinatorDelegate {
    func logoutFailed(error: AuthError)
    func logoutSucceeded()
}

class DashboardViewModel: BaseViewModel {
    
    weak var coordinatorDelegate: DashboardViewModelCoordinatorDelegate?
    
    var isTokenStackViewHidden: Bool {
        return !isCodeExchangeRequired && !isTokenRefreshEnabled
    }
    
    var isTokenDataHidden: Bool {
        return lastAccessTokenResponse == nil || lastRefreshTokenResponse == nil
    }
    
    var isProfileManagementDisabled: Bool {
        return !authenticator.authStateManager.isBrowserSessionActive
    }
    
    var isCodeExchangeRequired: Bool {
        return authenticator.authStateManager.isCodeExchangeRequired
    }
    
    var isGetUserInfoEnabled: Bool {
        return authenticator.authStateManager.isAuthStateActive
    }
    
    var isTokenRefreshEnabled: Bool {
        return authenticator.authStateManager.isRefreshTokenActive
    }
    
    var lastAccessTokenResponse: String? {
        return authenticator.authStateManager.lastAccessTokenResponse
    }
        
    var lastRefreshTokenResponse: String? {
        return authenticator.authStateManager.lastRefreshTokenResponse
    }
    
    var isTokenActive: Bool {
        return authenticator.authStateManager.isAccessTokenActive &&
                authenticator.authStateManager.isRefreshTokenActive
    }
    
    func checkBrowserSession() -> Void {
        
        isLoading = true
        // Do the login redirect on the main thread
        authenticator.startBrowserLogin(
            { session in
                self.appDelegate.currentAuthorizationFlow = session
            },
            { result in
                self.isLoading = false
                
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self.coordinatorDelegate?.displayAlert(error)
                    self.coordinatorDelegate?.logData(error.details)
                }
            }
        )
    }
    
    func loadProfileManagement() -> Void {
        isLoading = true
        // Do the login redirect on the main thread
        authenticator.startProfileManagement(
            { session in
                self.appDelegate.currentAuthorizationFlow = session
            },
            { result in
                self.isLoading = false
                
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self.coordinatorDelegate?.displayAlert(error)
                    self.coordinatorDelegate?.logData(error.details)
                }
            }
        )
    }
    
    func manualCodeExchange() -> Void {
        isLoading = true
        
        authenticator.performCodeExchange { result in
            self.isLoading = false
            
            switch result {
            case .success:
                break
            case .failure(let error):
                self.coordinatorDelegate?.displayAlert(error)
                self.coordinatorDelegate?.logData(error.details)
            }
        }
    }
    
    func refreshTokens() -> Void {
        isLoading = true
        
        authenticator.refreshAccessToken { result in
            self.isLoading = false
            
            switch result {
            case .success:
                break
            case .failure(let error):
                self.coordinatorDelegate?.displayAlert(error)
                self.coordinatorDelegate?.logData(error.details)
            }
        }
    }
    
    func getUserInfo() -> Void {
        isLoading = true
        
        authenticator.getUserInfo { result in
            self.isLoading = false
            
            switch result {
            case .success(let userInfo):
                self.coordinatorDelegate?.logData(userInfo)
            case .failure(let error):
                self.coordinatorDelegate?.displayAlert(error)
                self.coordinatorDelegate?.logData(error.details)
            }
        }
    }
    
    func getLogoutOptionsAlert() -> UIAlertController {
        let logoutViewController = LogoutOptionsController()
        
        let logoutAlertController = UIAlertController(title: "Sign Out Options", message: nil, preferredStyle: .alert)
        logoutAlertController.setValue(logoutViewController, forKey: "contentViewController")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            self.handleLogoutSelections(logoutViewController.selectedLogoutOptions)
        }
        
        logoutAlertController.addAction(cancelAction)
        logoutAlertController.addAction(submitAction)
        return logoutAlertController
    }
    
    func handleLogoutSelections(_ logoutSelections: Set<LogoutType>) -> Void {
        
        isLoading = true
        
        if ((logoutSelections.contains(LogoutType.revokeTokens)
             || logoutSelections.contains(LogoutType.appSession)) &&
            (authenticator.authStateManager.isAccessTokenActive
             || authenticator.authStateManager.isRefreshTokenActive)) {
            
            dispatchGroup.enter()
            
            dispatchQueue.async(group: dispatchGroup) {
                self.authenticator.expireToken(tokenType: .accessToken) { result in

                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        self.coordinatorDelegate?.displayAlert(error)
                        self.coordinatorDelegate?.logData(error.details)
                        self.dispatchGroup.leave()
                        return
                    }
                    
                    self.dispatchGroup.leave()
                }
            }
            
            dispatchGroup.enter()
            
            dispatchQueue.async(group: dispatchGroup) {
                self.authenticator.expireToken(tokenType: .refreshToken) { result in
                    
                    switch result {
                    case .success:
                        if !logoutSelections.contains(LogoutType.browserSession) || !logoutSelections.contains(LogoutType.appSession) {
                            self.dispatchGroup.leave()
                            return
                        }
                    case .failure(let error):
                        self.coordinatorDelegate?.displayAlert(error)
                        self.coordinatorDelegate?.logData(error.details)
                        self.dispatchGroup.leave()
                        return
                    }
                    
                    self.dispatchGroup.leave()
                }
            }
        }
        
        if logoutSelections.contains(LogoutType.browserSession) {
            
            dispatchGroup.enter()
            
            dispatchQueue.async(group: dispatchGroup) {
                // Do the logout redirect on the main thread
                self.authenticator.startBrowserLogout(
                    { session in
                        self.appDelegate.currentAuthorizationFlow = session
                    },
                    { result in
                        
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            self.coordinatorDelegate?.logoutFailed(error: error)
                            self.coordinatorDelegate?.logData(error.details)
                            self.dispatchGroup.leave()
                            return
                        }
                        
                        self.dispatchGroup.leave()
                    }
                )
            }
        }
        
        if logoutSelections.contains(LogoutType.appSession) {
            dispatchGroup.notify(queue: dispatchQueue) {
                self.authenticator.appSessionLogout()
                self.coordinatorDelegate?.logoutSucceeded()
            }
        } else {
            dispatchGroup.notify(queue: dispatchQueue) {
                self.isLoading = false
            }
        }
    }
}
