//
//  DashboardViewModel.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

protocol DashboardViewModelCoordinatorDelegate: AnyObject {
    func logoutSucceeded()
}

class DashboardViewModel: BaseViewModel {
    
    weak var coordinatorDelegate: DashboardViewModelCoordinatorDelegate?
    
    var discoveryConfig: String? {
        return authenticator.discoveryConfig?.description
    }
    var isTokenRequestStackViewHidden: Bool {
        !isCodeExchangeRequired && !isTokenActive
    }
    var isTokenDataStackViewHidden: Bool {
        lastAccessTokenResponse == nil || lastRefreshTokenResponse == nil
    }
    var isCodeExchangeRequired: Bool {
        authenticator.isCodeExchangeRequired
    }
    var isAccessTokenRevoked: Bool {
        authenticator.isAccessTokenRevoked
    }
    var isRefreshTokenRevoked: Bool {
        authenticator.isRefreshTokenRevoked
    }
    var lastAccessTokenResponse: String? {
        authenticator.lastTokenResponse?.accessToken
    }
    var lastRefreshTokenResponse: String? {
        authenticator.lastTokenResponse?.refreshToken
    }
    var isTokenActive: Bool {
        !authenticator.isAccessTokenRevoked &&
        !authenticator.isRefreshTokenRevoked &&
        lastAccessTokenResponse != nil &&
        lastRefreshTokenResponse != nil
    }
    var isBrowserSessionActive: Bool {
        authenticator.isBrowserSessionActive
    }
    
    func discoverConfiguration() async throws {
        do {
            try await authenticator.getDiscoveryConfig(AuthConfig.discoveryUrl)
            
            if let discoveryConfig = discoveryConfig {
                viewControllerDelegate?.printToLogTextView(discoveryConfig)
            } else {
                throw AuthError.noDiscoveryDoc
            }
        } catch let error as AuthError {
            viewControllerDelegate?.displayAlertWithAction(error, alertAction: {
                Task {
                    try await self.discoverConfiguration()
                }
            })
        }
        viewControllerDelegate?.stateChanged(false)
    }
    
    func checkBrowserSession() async throws {
        // Do the login redirect on the main thread
        try await MainActor.run {
            AppDelegate.shared.currentAuthorizationFlow = try authenticator.startBrowserLoginWithAutoCodeExchange()
        }
        
        // Handle the login response on a background thread
        let authStateResponse = try await authenticator.handleBrowserLoginWithAutoCodeExchangeResponse()
        
        try await authenticator.finishLoginWithAuthStateResponse(authStateResponse)
        
        viewControllerDelegate?.stateChanged(false)
    }
    
    func loadProfileManagement() async throws {
        // Do the login redirect on the main thread
        try await MainActor.run {
            AppDelegate.shared.currentAuthorizationFlow = try authenticator.startProfileManagementRedirect()
        }
        
        try await authenticator.handleProfileManagementResponse()
        viewControllerDelegate?.stateChanged(false)
    }
    
    func refreshTokens() async throws {
        if !authenticator.isCodeExchangeRequired {
            try await authenticator.refreshTokens()
            viewControllerDelegate?.stateChanged(false)
        }
    }
    
    func getUserInfo() async throws {
        if let userInfo = try await authenticator.performUserInfoRequest() {
            viewControllerDelegate?.printToLogTextView(userInfo)
        }
        viewControllerDelegate?.stateChanged(false)
    }
    
    func exchangeAuthorizationCode() async throws {
        try await authenticator.exchangeAuthorizationCode()
        viewControllerDelegate?.stateChanged(false)
    }
    
    func getLogoutOptionsAlert() -> UIAlertController {
        let logoutAlertController = LogoutOptionsAlertController(title: "Sign Out Options", message: nil, preferredStyle: .alert)
        logoutAlertController.delegate = self
        
        return logoutAlertController
    }
    
    func revokeTokens() async throws {
        try await authenticator.revokeToken(tokenType: .accessToken)
        try await authenticator.revokeToken(tokenType: .refreshToken)
    }
    
    func browserLogout() async throws {
        // Do the logout redirect on the main thread
        try await MainActor.run {
            AppDelegate.shared.currentAuthorizationFlow = try authenticator.startBrowserLogoutRedirect()
        }
        
        // Handle the logout response on a background thread
        let response = try await authenticator.handleBrowserLogoutResponse()
        
        try await authenticator.finishBrowserLogout(response)
    }
    
    func appLogout() async throws {
        try await authenticator.performAppSessionLogout()
        
        if !authenticator.isAuthStateActive {
            coordinatorDelegate?.logoutSucceeded()
        }
    }
}

extension DashboardViewModel: LogoutAlertDelegate {
    
    func handleLogoutSelections(_ selections: Set<LogoutType>) {
        Task {
            viewControllerDelegate?.stateChanged(true)
            
            do {
                if ((selections.contains(LogoutType.revokeTokens) ||
                     selections.contains(LogoutType.appSession)) &&
                    (!isAccessTokenRevoked && !isRefreshTokenRevoked) &&
                    isTokenActive) {
                    
                    try await revokeTokens()
                }
                
                if selections.contains(LogoutType.browserSession) &&
                    authenticator.isBrowserSessionActive {
                    try await browserLogout()
                }
                
                if selections.contains(LogoutType.appSession) {
                    try await appLogout()
                }
            } catch let error as AuthError {
                self.viewControllerDelegate?.displayErrorAlert(error)
                self.viewControllerDelegate?.printToLogTextView(error.errorUserInfo.debugDescription)
            }
            
            self.viewControllerDelegate?.stateChanged(false)
        }
    }
}
