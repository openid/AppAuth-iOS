//
//  LoginViewModel.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

protocol LoginViewModelCoordinatorDelegate: AnyObject {    
    func loginSucceeded(with authenticator: Authenticator)
}

class LoginViewModel: BaseViewModel {
    
    weak var coordinatorDelegate: LoginViewModelCoordinatorDelegate?
    
    var isManualCodeExchange = false
    var discoveryConfig: String? {
        return authenticator.discoveryConfig?.description
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
    
    func beginBrowserAuthentication() async throws {
        try await isManualCodeExchange ? authWithManualCodeExchange() : authWithAutoCodeExchange()
        viewControllerDelegate?.stateChanged(false)
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
