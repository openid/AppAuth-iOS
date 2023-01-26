//
//  DashboardCoordinator.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

protocol DashboardCoordinatorDelegate: AnyObject {
    func didFinishDashboardCordinator(coordinator: Coordinator, with authenticator: AuthenticationManager)
}

class DashboardCoordinator: BaseCoordinator {
    
    private let navigationcontroller: UINavigationController
    weak var delegate: DashboardCoordinatorDelegate?
    private let authenticator: AuthenticationManager
    
    init(navigationcontroller: UINavigationController, with authenticator: AuthenticationManager) {
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
        let viewModel = DashboardViewModel(authenticator: authenticator)
        viewModel.coordinatorDelegate = self
        viewModel.baseCoordinatorDelegate = self
        
        let controller = DashboardViewController.instantiate(from: .Main)
        controller.viewModel = viewModel
        
        return controller
    }()
}

extension DashboardCoordinator: DashboardViewModelCoordinatorDelegate {
    
    func logoutSucceeded() {
        delegate?.didFinishDashboardCordinator(coordinator: self, with: authenticator)
    }
    
    func logoutFailed(error: AuthError) {
        dashboardController?.displayAlert(error: error)
    }
    
    func stateChanged(_ isLoading: Bool) {
        dashboardController?.setActivityIndicator(isLoading)
        dashboardController?.updateUI()
    }
    
    func logData(_ data: String?) {
        guard let data = data else { return }
        dashboardController?.printToLogTextView(data)
    }
    
    func displayAlert(_ error: AuthError?) {
        dashboardController?.displayAlert(error: error)
    }
    
    func displayActionAlert(_ error: AuthError?, alertAction: AlertAction) {
        dashboardController?.displayAlert(error: error, alertAction: alertAction)
    }
}
