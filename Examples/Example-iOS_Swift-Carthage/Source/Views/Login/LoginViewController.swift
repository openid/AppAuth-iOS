//
//  LoginViewController.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

@MainActor
class LoginViewController: UIViewController {
    
    @IBOutlet private weak var authButton: UIButton!
    @IBOutlet weak var authTypeSegementedControl: UISegmentedControl!
    @IBOutlet private weak var logTextView: UITextView!
    
    var viewModel: LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        Task {
            setActivityIndicator(true)
            
            do {
                try await viewModel.discoverConfiguration()
            } catch let error as AuthError {
                displayAlert(error: error)
            } catch {
                printToLogTextView(error.localizedDescription)
            }
        }
    }
}

//MARK: IBActions
extension LoginViewController {
    
    @IBAction func authorizeUser(_ sender: UIButton) {
        
        Task {
            setActivityIndicator(true)
            
            do {
                try await viewModel.beginBrowserAuthentication()
            } catch let error as AuthError {
                displayAlert(error: error)
                printToLogTextView(error.errorUserInfo.debugDescription)
            } catch {
                printToLogTextView(error.localizedDescription)
            }
        }
    }
    
    @IBAction func authTypeSelectionChanged(_ sender: UISegmentedControl) {
        viewModel.isManualCodeExchange = sender.selectedSegmentIndex == 1
    }
    
    @IBAction func clearLog(_ sender: UIButton) {
        logTextView.text = ""
    }
}

extension LoginViewController {
    
    func configureUI() {
        logTextView.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        logTextView.layer.borderWidth = 1.0
        logTextView.alwaysBounceVertical = true
        logTextView.textContainer.lineBreakMode = .byCharWrapping
        logTextView.text = ""
    }
}

extension LoginViewController: BaseViewControllerDelegate {
    
    func stateChanged(_ isLoading: Bool?) {
        if let isLoading = isLoading {
            self.setActivityIndicator(isLoading)
        }
    }
    
    func displayErrorAlert(_ error: AuthError?) {
        displayAlert(error: error)
    }
    
    func displayAlertWithAction(_ error: AuthError?, alertAction: AlertAction) {
        displayAlert(error: error, alertAction: alertAction)
    }
    
    func printToLogTextView(_ data: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        
        // Appends to output log
        DispatchQueue.main.async {
            let logText = "\(self.logTextView.text ?? "")\n\(dateString): \(data)"
            self.logTextView.text = logText
            
            let range = NSMakeRange(self.logTextView.text.count - 1, 0)
            self.logTextView.scrollRangeToVisible(range)
        }
    }
}
