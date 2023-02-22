//
//  BaseViewController.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

protocol BaseViewControllerDelegate: AnyObject {
    typealias AlertAction = (() -> Void)?
    
    func stateChanged(_ isLoading: Bool?)
    func printToLogTextView(_ data: String)
    func displayErrorAlert(_ error: AuthError?)
    func displayAlertWithAction(_ error: AuthError?, alertAction: AlertAction)
}
