//
//  LoginViewModel.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

protocol LoginViewModelCoordinatorDelegate: AnyObject {
    func loginSucceeded(with authenticator: AuthenticatorProtocol)
}

// MARK: LoginViewModelProtocol
protocol LoginViewModelProtocol: BaseViewModel {
    var coordinatorDelegate: LoginViewModelCoordinatorDelegate? { get set }
    var isManualCodeExchange: Bool { get }
    
    func setManualCodeExchange(_ isSelected: Bool)
    func discoverConfiguration() async throws -> String
    func beginBrowserAuthentication() async throws -> Void
    func authWithAutoCodeExchange() async throws -> Void
    func authWithManualCodeExchange() async throws -> Void
}

class LoginViewModel: BaseViewModel, LoginViewModelProtocol {
    
    weak var coordinatorDelegate: LoginViewModelCoordinatorDelegate?
    
    var isManualCodeExchange: Bool {
        authenticator.isCodeExchangeRequired
    }
    
    func setManualCodeExchange(_ isSelected: Bool) {
        authenticator.isCodeExchangeRequired = isSelected
    }
    
    func discoverConfiguration() async throws -> String {
        return try await authenticator.loadDiscoveryConfig()
    }
    
    func beginBrowserAuthentication() async throws {
        try await isManualCodeExchange ? authWithManualCodeExchange() : authWithAutoCodeExchange()
    }
    
    func authWithAutoCodeExchange() async throws {
        
        // Do the login redirect on the main thread
        try await MainActor.run {
            AppDelegate.shared.currentAuthorizationFlow = try authenticator.startBrowserLoginWithAutoCodeExchange()
        }
        
        // Handle the login response on a background thread
        let authStateResponse = try await authenticator.handleBrowserLoginWithAutoCodeExchangeResponse()
        
        try await authenticator.finishLoginWithAuthStateResponse(authStateResponse)
        
        await MainActor.run {
            coordinatorDelegate?.loginSucceeded(with: authenticator)
        }
    }
    
    func authWithManualCodeExchange() async throws {
        
        // Do the login redirect on the main thread
        try await MainActor.run {
            AppDelegate.shared.currentAuthorizationFlow = try authenticator.startBrowserLoginWithManualCodeExchange()
        }
        
        let authResponse = try await authenticator.handleBrowserLoginWithManualCodeExchangeResponse()
        
        try await authenticator.finishLoginWithAuthResponse(authResponse)
        
        await MainActor.run {
            coordinatorDelegate?.loginSucceeded(with: authenticator)
        }
    }
}
