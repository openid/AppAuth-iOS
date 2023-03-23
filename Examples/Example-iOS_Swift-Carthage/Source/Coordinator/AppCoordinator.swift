//
//  AppCoordinator.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit
import AppAuth

@MainActor
class AppCoordinator: BaseCoordinator {
    
    // MARK: - Properties
    let window: UIWindow?
    var authenticator: AuthenticatorProtocol?
    
    lazy var rootViewController: UINavigationController = {
        return UINavigationController()
    }()
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    override func start() {
        guard let window = window else { return }
        rootViewController.setNavigationBarHidden(true, animated: false)
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        
        let authConfig = AuthConfig()
        let authStateManager = AuthStateManager(authConfig)
        authenticator = Authenticator(authConfig,
                                      rootViewController: rootViewController,
                                      authStateManager: authStateManager,
                                      OIDAuthState: OIDAuthState.self,
                                      OIDAuthorizationService: OIDAuthorizationService.self)
        
        if let authenticator = self.authenticator {
            if authenticator.isAuthStateActive {
                dashboardFlow(with: authenticator)
            } else {
                loginFlow(with: authenticator)
            }
        } else {
            rootViewController.displayAlert(error: AuthError.noAuthState)
        }
    }
    
    private func loginFlow(with authenticator: AuthenticatorProtocol) {
        let loginCoordinator = LoginCoordinator(navigationcontroller: rootViewController, with: authenticator)
        loginCoordinator.delegate = self
        store(coordinator: loginCoordinator)
        loginCoordinator.start()
    }
    
    private func dashboardFlow(with authenticator: AuthenticatorProtocol) {
        let dashboardCoordinator = DashboardCoordinator(navigationcontroller: rootViewController, with: authenticator)
        dashboardCoordinator.delegate = self
        store(coordinator: dashboardCoordinator)
        dashboardCoordinator.start()
    }
    
    private func logoutFlow(with authenticator: AuthenticatorProtocol) {
        let loginCoordinator = LoginCoordinator(navigationcontroller: rootViewController, with: authenticator)
        loginCoordinator.delegate = self
        store(coordinator: loginCoordinator)
        guard let loginController = loginCoordinator.loginController else { return }
        DispatchQueue.main.async {
            self.rootViewController.viewControllers.insert(loginController, at: 0)
            self.rootViewController.popViewController(animated: true)
        }
        loginCoordinator.start()
    }
}

extension AppCoordinator: LoginCoordinatorDelegate {
    func didFinishLoginCordinator(coordinator: Coordinator, with authenticator: AuthenticatorProtocol) {
        free(coordinator: coordinator)
        dashboardFlow(with: authenticator)
    }
}

extension AppCoordinator: DashboardCoordinatorDelegate {
    func didFinishDashboardCordinator(coordinator: Coordinator, with authenticator: AuthenticatorProtocol) {
        free(coordinator: coordinator)
        logoutFlow(with: authenticator)
    }
}
