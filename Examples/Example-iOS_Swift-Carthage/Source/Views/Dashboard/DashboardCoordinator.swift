//
//  DashboardCoordinator.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

protocol DashboardCoordinatorDelegate: AnyObject {
    func didFinishDashboardCordinator(coordinator: Coordinator, with authenticator: AuthenticatorProtocol)
}

// DashboardCoordinator handles the responsibility if navigation in Dashboard module
@MainActor
class DashboardCoordinator: BaseCoordinator {
    
    private let navigationcontroller: UINavigationController
    weak var delegate: DashboardCoordinatorDelegate?
    private let authenticator: AuthenticatorProtocol
    
    init(navigationcontroller: UINavigationController, with authenticator: AuthenticatorProtocol) {
        self.navigationcontroller = navigationcontroller
        self.authenticator = authenticator
    }
    
    override func start() {
        if let controller = self.dashboardController {
            DispatchQueue.main.async {
                self.navigationcontroller.pushViewController(controller, animated: true)
            }
        }
    }
    
    // Init DashboardViewController with ViewModel dependency injection
    lazy var dashboardController: DashboardViewController? = {
        let viewModel = DashboardViewModel(authenticator)
        viewModel.coordinatorDelegate = self
        
        let controller = DashboardViewController.instantiate(from: .Main)
        controller.viewModel = viewModel
        viewModel.viewControllerDelegate = controller
        
        return controller
    }()
}

extension DashboardCoordinator: DashboardViewModelCoordinatorDelegate {
    func logoutSucceeded() {
        delegate?.didFinishDashboardCordinator(coordinator: self, with: authenticator)
    }
}
