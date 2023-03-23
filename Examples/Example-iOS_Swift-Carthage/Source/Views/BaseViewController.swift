//
//  BaseViewController.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

protocol BaseViewControllerDelegate: AnyObject {
    func printToLogTextView(_ data: String)
}

class BaseViewController: UIViewController {
    
    typealias AlertAction = (() -> Void)?
    
    func displayErrorAlert(_ error: AuthError?) {
        displayAlert(error: error)
    }
    
    func displayAlertWithAction(_ error: AuthError?, alertAction: (() -> Void)?) {
        displayAlert(error: error, alertAction: alertAction)
    }
}
