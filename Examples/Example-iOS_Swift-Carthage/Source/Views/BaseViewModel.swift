//
//  BaseViewModel.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

@MainActor
class BaseViewModel: NSObject {
    weak var viewControllerDelegate: BaseViewControllerDelegate?
    internal var authenticator: Authenticator
    
    init(_ authenticator: Authenticator) {
        self.authenticator = authenticator
        super.init()
        
        authenticator.delegate = self
    }
}

extension BaseViewModel: AuthenticatorDelegate {
    func logMessage(_ message: String) {
        viewControllerDelegate?.printToLogTextView(message)
    }
}
