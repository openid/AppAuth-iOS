//
//  BaseViewModel.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

protocol BaseViewModelCoordinatorDelegate: AnyObject {
    
    typealias AlertAction = (() -> Void)?
    
    func logData(_ data: String?)
    func displayAlert(_ error: AuthError?)
    func displayActionAlert(_ error: AuthError?, alertAction: AlertAction)
    func stateChanged(_ isLoading: Bool)
}

extension BaseViewModelCoordinatorDelegate {
    
    func displayAlert(_ error: AuthError?) {
        logData(error?.details)
    }
    func displayActionAlert(_ error: AuthError?, alertAction: AlertAction) {
        logData(error?.details)
    }
}

class BaseViewModel: NSObject {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    weak var baseCoordinatorDelegate: BaseViewModelCoordinatorDelegate?
        
    let authenticator: AuthenticationManager
    var metadata: String? = nil
    
    let operationQueue = OperationQueue()
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue.main
    
    var isLoading = false {
        didSet {
            baseCoordinatorDelegate?.stateChanged(isLoading)
        }
    }
    
    init(authenticator: AuthenticationManager) {
        self.authenticator = authenticator
    }
    
    func discoverConfig() {
        isLoading = true
        
        authenticator.discoverConfig { result in
            self.isLoading = false
            
            switch result {
            case .success:
                if let metadataString = self.authenticator.metadata?.description {
                    self.baseCoordinatorDelegate?.logData(metadataString)
                }
            case .failure(let error):
                self.baseCoordinatorDelegate?.logData(error.details)
                self.baseCoordinatorDelegate?.displayActionAlert(
                    AuthError(.configurationLoadingError),
                    alertAction: {
                        self.discoverConfig()
                })
            }
        }
    }
}

extension BaseViewModel: AuthStateDelegate {
    func authStateChanged() {
        baseCoordinatorDelegate?.stateChanged(isLoading)
    }
    
    func authStateErrorOccured(_ error: AuthError) {
        baseCoordinatorDelegate?.logData(error.details)
        
        if error.errorCode != nil {
            baseCoordinatorDelegate?.displayAlert(error)
        }
    }
}
