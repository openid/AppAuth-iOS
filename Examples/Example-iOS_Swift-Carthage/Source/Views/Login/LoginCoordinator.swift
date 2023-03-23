//
//  LoginCoordinator.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

protocol LoginCoordinatorDelegate: AnyObject {
    func didFinishLoginCordinator(coordinator: Coordinator, with authenticator: AuthenticatorProtocol)
}

// LoginCoordinator handles the responsibility if navigation in Login module
@MainActor
final class LoginCoordinator: BaseCoordinator {
    
    private let navigationcontroller: UINavigationController
    weak var delegate: LoginCoordinatorDelegate?
    private let authenticator: AuthenticatorProtocol
    
    init(navigationcontroller: UINavigationController, with authenticator: AuthenticatorProtocol) {
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
    
    // init LoginViewController
    lazy var loginController: LoginViewController? = {
        let viewModel = LoginViewModel(authenticator)
        viewModel.coordinatorDelegate = self
        
        let controller = LoginViewController.instantiate(from: .Main)
        controller.viewModel = viewModel
        viewModel.viewControllerDelegate = controller
        
        return controller
    }()
}

extension LoginCoordinator: LoginViewModelCoordinatorDelegate {
    func loginSucceeded(with authenticator: AuthenticatorProtocol) {
        delegate?.didFinishLoginCordinator(coordinator: self, with: authenticator)
    }
}
