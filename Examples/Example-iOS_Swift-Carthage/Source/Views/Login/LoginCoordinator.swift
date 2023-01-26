//
//  LoginCoordinator.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

protocol LoginCoordinatorDelegate: AnyObject {
    func didFinishLoginCordinator(coordinator: Coordinator, with authenticator: AuthenticationManager)
}

/// LoginCoordinator handles the responsibility if naviagtion in login-module
final class LoginCoordinator: BaseCoordinator {
    
    private let navigationcontroller: UINavigationController
    weak var delegate: LoginCoordinatorDelegate?
    private let authenticator: AuthenticationManager
    
    init(navigationcontroller: UINavigationController, with authenticator: AuthenticationManager) {
        self.navigationcontroller = navigationcontroller
        self.authenticator = authenticator
    }
    
    override func start() {
        if let controller = self.loginController {
            DispatchQueue.main.async {
                self.navigationcontroller.setViewControllers([controller], animated: false)
            }
        }
    }
    
    // init login-controller
    lazy var loginController: LoginViewController? = {
        let viewModel = LoginViewModel(authenticator: authenticator)
        viewModel.coordinatorDelegate = self
        viewModel.baseCoordinatorDelegate = self
        
        let controller = LoginViewController.instantiate(from: .Main)
        controller.viewModel = viewModel
        
        return controller
    }()
}

extension LoginCoordinator: LoginViewModelCoordinatorDelegate {
    
    func stateChanged(_ isLoading: Bool) {
        loginController?.setActivityIndicator(isLoading)
        loginController?.updateUI()
    }

    func loginFailed(error: AuthError) {
        loginController?.displayAlert(error: error)
    }
    
    func loginSucceeded(with authenticator: AuthenticationManager) {
        delegate?.didFinishLoginCordinator(coordinator: self, with: authenticator)
    }
    
    func logData(_ data: String?) {
        guard let data = data else { return }
        loginController?.printToLogTextView(data)
    }
    
    func displayAlert(_ error: AuthError?) {
        loginController?.displayAlert(error: error)
    }
    
    func displayActionAlert(_ error: AuthError?, alertAction: AlertAction) {
        loginController?.displayAlert(error: error, alertAction: alertAction)
    }
}
