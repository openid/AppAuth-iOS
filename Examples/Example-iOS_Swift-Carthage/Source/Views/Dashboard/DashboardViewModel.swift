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

// MARK: DashboardViewModelProtocol
protocol DashboardViewModelProtocol: BaseViewModel {
    var coordinatorDelegate: DashboardViewModelCoordinatorDelegate? { get set }
    
    var isBrowserSessionActive: Bool { get }
    var isTokenRequestStackViewHidden: Bool { get }
    var isTokenDataStackViewHidden: Bool { get }
    var isCodeExchangeButtonHidden: Bool { get }
    var isRefreshTokenButtonHidden: Bool { get }
    var isUserinfoButtonHidden: Bool { get }
    var isProfileButtonHidden: Bool { get }
    var accessTokenTextViewText: String { get }
    var accessTokenTitleLabelText: String { get }
    var refreshTokenTextViewText: String { get }
    var refreshTokenTitleLabelText: String { get }
    func discoverConfiguration() async throws -> String
    func checkBrowserSession() async throws -> Void
    func loadProfileManagement() async throws -> Void
    func refreshTokens() async throws -> Void
    func getUserInfo() async throws -> String
    func exchangeAuthorizationCode() async throws -> Void
    func getLogoutOptionsAlert(_ completion: @escaping LogoutAlertCompletionHandler) -> UIAlertController
    func revokeTokens() async throws -> Void
    func browserLogout() async throws -> Void
    func appLogout() async throws -> Void
    func handleLogoutSelections(_ selections: Set<LogoutType>, completion: LogoutAlertCompletionHandler?) -> Void
}

class DashboardViewModel: BaseViewModel, DashboardViewModelProtocol {
    
    weak var coordinatorDelegate: DashboardViewModelCoordinatorDelegate?
    
    private var isCodeExchangeRequired: Bool {
        authenticator.isCodeExchangeRequired
    }
    private var isAccessTokenRevoked: Bool {
        authenticator.isAccessTokenRevoked
    }
    private var isRefreshTokenRevoked: Bool {
        authenticator.isRefreshTokenRevoked
    }
    private var lastAccessTokenResponse: String? {
        authenticator.lastTokenResponse?.accessToken
    }
    private var lastRefreshTokenResponse: String? {
        authenticator.lastTokenResponse?.refreshToken
    }
    private var isTokenActive: Bool {
        !authenticator.isAccessTokenRevoked &&
        !authenticator.isRefreshTokenRevoked &&
        lastAccessTokenResponse != nil &&
        lastRefreshTokenResponse != nil
    }
    
    var isBrowserSessionActive: Bool {
        authenticator.isBrowserSessionActive
    }
    
    // MARK: UI State Properties
    var isTokenRequestStackViewHidden: Bool {
        !isCodeExchangeRequired && !isTokenActive
    }
    var isTokenDataStackViewHidden: Bool {
        lastAccessTokenResponse == nil || lastRefreshTokenResponse == nil
    }
    var isCodeExchangeButtonHidden: Bool {
        !isCodeExchangeRequired
    }
    var isRefreshTokenButtonHidden: Bool {
        !isTokenActive
    }
    var isUserinfoButtonHidden: Bool {
        !isTokenActive
    }
    var isProfileButtonHidden: Bool {
        !isBrowserSessionActive
    }
    var accessTokenTextViewText: String {
        lastAccessTokenResponse ?? ""
    }
    var accessTokenTitleLabelText: String {
        isAccessTokenRevoked ? TextConstants.accessTokenRevoked : TextConstants.accessToken
    }
    var refreshTokenTextViewText: String {
        lastRefreshTokenResponse ?? ""
    }
    var refreshTokenTitleLabelText: String {
        isRefreshTokenRevoked ? TextConstants.refreshTokenRevoked : TextConstants.refreshToken
    }
    
    func discoverConfiguration() async throws -> String {
        return try await authenticator.loadDiscoveryConfig()
    }
    
    func checkBrowserSession() async throws {
        // Do the login redirect on the main thread
        try await MainActor.run {
            AppDelegate.shared.currentAuthorizationFlow = try authenticator.startBrowserLoginWithAutoCodeExchange()
        }
        
        // Handle the login response on a background thread
        let authStateResponse = try await authenticator.handleBrowserLoginWithAutoCodeExchangeResponse()
        
        try await authenticator.finishLoginWithAuthStateResponse(authStateResponse)
    }
    
    func loadProfileManagement() async throws {
        // Do the login redirect on the main thread
        try await MainActor.run {
            AppDelegate.shared.currentAuthorizationFlow = try authenticator.startProfileManagementRedirect()
        }
        
        try await authenticator.handleProfileManagementResponse()
    }
    
    func refreshTokens() async throws {
        if !authenticator.isCodeExchangeRequired {
            try await authenticator.refreshTokens()
        }
    }
    
    func getUserInfo() async throws -> String {
        return try await authenticator.performUserInfoRequest()
    }
    
    func exchangeAuthorizationCode() async throws {
        try await authenticator.exchangeAuthorizationCode()
    }
    
    func getLogoutOptionsAlert(_ completion: @escaping LogoutAlertCompletionHandler) -> UIAlertController {
        let logoutAlertController = LogoutOptionsAlertController(title: "Sign Out Options", message: nil, preferredStyle: .alert)
        logoutAlertController.delegate = self
        logoutAlertController.completionHandler = completion
        
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
    
    func handleLogoutSelections(_ selections: Set<LogoutType>, completion: LogoutAlertCompletionHandler?) {
        Task {
            do {
                if selections.contains(LogoutType.browserSession) &&
                    authenticator.isBrowserSessionActive {
                    try await browserLogout()
                }
                
                if (selections.contains(LogoutType.revokeTokens) &&
                    !selections.contains(LogoutType.appSession) &&
                    (!isAccessTokenRevoked && !isRefreshTokenRevoked) &&
                    isTokenActive)
                {
                    try await revokeTokens()
                }
                
                if selections.contains(LogoutType.appSession) {
                    try? await revokeTokens()
                    try await appLogout()
                }
            } catch let error as AuthError {
                completion?(Result.failure(error))
            }
            
            completion?(Result.success(true))
        }
    }
}
