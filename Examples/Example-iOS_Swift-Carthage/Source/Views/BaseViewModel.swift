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
    private(set) var authenticator: AuthenticatorProtocol
    
    init(_ authenticator: AuthenticatorProtocol) {
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
