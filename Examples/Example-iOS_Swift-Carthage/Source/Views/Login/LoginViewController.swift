//
//  LoginViewController.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

@MainActor
class LoginViewController: BaseViewController {
    
    @IBOutlet private(set) weak var authButton: UIButton!
    @IBOutlet private(set) weak var authTypeSegementedControl: UISegmentedControl!
    @IBOutlet private(set) weak var logTextView: UITextView!
    
    var viewModel: LoginViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        discoverConfig()
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
            
            setActivityIndicator(false)
        }
    }
    
    @IBAction func authTypeSelectionChanged(_ sender: UISegmentedControl) {
        viewModel.setManualCodeExchange(sender.selectedSegmentIndex == 1)
    }
    
    @IBAction func clearLog(_ sender: UIButton) {
        logTextView.text = ""
    }
}

extension LoginViewController {
    
    func discoverConfig() {
        Task {
            setActivityIndicator(true)
            
            do {
                let discoveryConfig = try await viewModel.discoverConfiguration()
                printToLogTextView(discoveryConfig)
            } catch let error as AuthError {
                displayAlertWithAction(error, alertAction: {
                    Task {
                        try await self.viewModel.discoverConfiguration()
                    }
                })
            }
            
            setActivityIndicator(false)
        }
    }
    
    func configureUI() {
        logTextView.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        logTextView.layer.borderWidth = 1.0
        logTextView.alwaysBounceVertical = true
        logTextView.textContainer.lineBreakMode = .byCharWrapping
        logTextView.text = ""
    }
}

extension LoginViewController: BaseViewControllerDelegate {
    
    func printToLogTextView(_ data: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        
        // Appends to output log
        DispatchQueue.main.async {
            let logText = "\(self.logTextView.text ?? "")\(dateString): \(data)\n\n"
            self.logTextView.text = logText
            
            let range = NSMakeRange(self.logTextView.text.count - 1, 0)
            self.logTextView.scrollRangeToVisible(range)
        }
    }
}
