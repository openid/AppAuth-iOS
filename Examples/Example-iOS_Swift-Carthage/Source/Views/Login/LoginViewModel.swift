//
//  LoginViewModel.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

protocol LoginViewModelCoordinatorDelegate: BaseViewModelCoordinatorDelegate {
    func loginSucceeded(with authenticator: AuthenticationManager)
    func loginFailed(error: AuthError)
}

class LoginViewModel: BaseViewModel {
    
    weak var coordinatorDelegate: LoginViewModelCoordinatorDelegate?
    var isManualCodeExchange = false
    
    func onTapLogin() -> Void {
        
        isLoading = true
        
        isManualCodeExchange ? authWithManualCodeExchange() : authWithAutoCodeExchange()
    }
    
    func authWithAutoCodeExchange() {
        // Do the login redirect on the main thread
        self.authenticator.startBrowserLogin(
            { session in
                self.appDelegate.currentAuthorizationFlow = session
            },
            { result in
                self.isLoading = false
                
                switch result {
                case .success:
                    self.coordinatorDelegate?.loginSucceeded(with: self.authenticator)
                case .failure(let error):
                    self.coordinatorDelegate?.loginFailed(error: error)
                    self.coordinatorDelegate?.logData(error.details)
                }
            }
        )
    }
    
    func authWithManualCodeExchange() {
        // Do the login redirect on the main thread
        self.authenticator.startBrowserLoginWithManualCodeExchange(
            { session in
                self.appDelegate.currentAuthorizationFlow = session
            },
            { result in
                self.isLoading = false
                
                switch result {
                case .success:
                    self.coordinatorDelegate?.loginSucceeded(with: self.authenticator)
                case .failure(let error):
                    self.coordinatorDelegate?.loginFailed(error: error)
                    self.coordinatorDelegate?.logData(error.details)
                }
            }
        )
    }
}
