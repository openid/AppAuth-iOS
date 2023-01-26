//
//  AppCoordinator.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

class AppCoordinator: BaseCoordinator {
    
    // MARK: - Properties
    let window: UIWindow?
    var authenticator: AuthenticationManager?
    
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
        
        authenticator = AuthenticationManager(rootViewController)
        
        if let authenticator = self.authenticator {
            if authenticator.authStateManager.isAppSessionActive {
                dashboardFlow(with: authenticator)
            } else {
                loginFlow(with: authenticator)
            }
        } else {
            rootViewController.displayAlert(error: AuthError(.authManagerLoadingError))
        }
    }
    
    private func loginFlow(with authenticator: AuthenticationManager) {
        let loginCoordinator = LoginCoordinator(navigationcontroller: rootViewController, with: authenticator)
        loginCoordinator.delegate = self
        store(coordinator: loginCoordinator)
        loginCoordinator.start()
    }
    
    private func dashboardFlow(with authenticator: AuthenticationManager) {
        let dashboardCoordinator = DashboardCoordinator(navigationcontroller: rootViewController, with: authenticator)
        dashboardCoordinator.delegate = self
        store(coordinator: dashboardCoordinator)
        dashboardCoordinator.start()
    }
    
    private func logoutFlow(with authenticator: AuthenticationManager) {
        let loginCoordinator = LoginCoordinator(navigationcontroller: rootViewController, with: authenticator)
        loginCoordinator.delegate = self
        store(coordinator: loginCoordinator)
        guard let loginController = loginCoordinator.loginController else { return }
        rootViewController.viewControllers.insert(loginController, at: 0)
        loginCoordinator.start()
    }
}

extension AppCoordinator: LoginCoordinatorDelegate {
    func didFinishLoginCordinator(coordinator: Coordinator, with authenticator: AuthenticationManager) {
        free(coordinator: coordinator)
        dashboardFlow(with: authenticator)
    }
}

extension AppCoordinator: DashboardCoordinatorDelegate {
    func didFinishDashboardCordinator(coordinator: Coordinator, with authenticator: AuthenticationManager) {
        free(coordinator: coordinator)
        logoutFlow(with: authenticator)
        rootViewController.popViewController(animated: true)
    }
}
