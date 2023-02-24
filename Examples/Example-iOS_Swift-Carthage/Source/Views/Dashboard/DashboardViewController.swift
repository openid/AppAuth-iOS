//
//  DashboardViewController.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

@MainActor
class DashboardViewController: UIViewController {
    
    @IBOutlet private weak var tokenRequestStackView: UIStackView!
    @IBOutlet private weak var codeExchangeButton: UIButton!
    @IBOutlet private weak var userinfoButton: UIButton!
    @IBOutlet private weak var refreshTokenButton: UIButton!
    @IBOutlet private weak var browserButton: UIButton!
    @IBOutlet private weak var profileButton: UIButton!
    @IBOutlet private weak var logTextView: UITextView!
    @IBOutlet private weak var tokenDataStackView: UIStackView!
    @IBOutlet private weak var accessTokenTitleLabel: UILabel!
    @IBOutlet private weak var refreshTokenTitleLabel: UILabel!
    @IBOutlet private weak var accessTokenTextView: UITextView!
    @IBOutlet private weak var refreshTokenTextView: UITextView!
    @IBOutlet private weak var accessTokenStackView: UIStackView!
    @IBOutlet private weak var refreshTokenStackView: UIStackView!
    
    var viewModel: DashboardViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        Task {
            setActivityIndicator(true)
            
            do {
                try await viewModel.discoverConfiguration()
                try await viewModel.refreshTokens()
            } catch let error as AuthError {
                displayAlert(error: error) {
                    Task {
                        try await self.viewModel.appLogout()
                    }
                }
            }
        }
    }
}

//MARK: IBActions
extension DashboardViewController {
    
    @IBAction func checkBrowserSession(_ sender: UIButton) {
        Task {
            setActivityIndicator(true)
            
            do {
                try await viewModel.checkBrowserSession()
            } catch let error as AuthError {
                displayAlert(error: error) {
                    if error == .userCancelledAuthorizationFlow && !self.viewModel.isBrowserSessionActive {
                        Task {
                            try await self.viewModel.appLogout()
                        }
                    } else {
                        self.printToLogTextView(error.errorUserInfo.debugDescription)
                    }
                }
            } catch {
                printToLogTextView(error.localizedDescription)
            }
        }
    }
    
    @IBAction func codeExchange(_ sender: UIButton) {
        Task {
            setActivityIndicator(true)
            
            do {
                try await viewModel.exchangeAuthorizationCode()
            } catch let error as AuthError {
                displayAlert(error: error)
                printToLogTextView(error.errorUserInfo.debugDescription)
            } catch {
                printToLogTextView(error.localizedDescription)
            }
        }
    }
    
    @IBAction func userinfo(_ sender: UIButton) {
        Task {
            setActivityIndicator(true)
            
            do {
                try await viewModel.getUserInfo()
            } catch let error as AuthError {
                displayAlert(error: error)
                printToLogTextView(error.errorUserInfo.debugDescription)
            } catch {
                printToLogTextView(error.localizedDescription)
            }
        }
    }
    
    @IBAction func refreshToken(_ sender: UIButton) {
        Task {
            setActivityIndicator(true)
            
            do {
                try await viewModel.refreshTokens()
            } catch let error as AuthError {
                displayAlert(error: error)
                printToLogTextView(error.errorUserInfo.debugDescription)
            } catch {
                printToLogTextView(error.localizedDescription)
            }
        }
    }
    
    @IBAction func profileManagement(_ sender: UIButton) {
        Task {
            setActivityIndicator(true)
            
            do {
                try await viewModel.loadProfileManagement()
            } catch let error as AuthError {
                displayAlert(error: error)
                printToLogTextView(error.errorUserInfo.debugDescription)
            } catch {
                printToLogTextView(error.localizedDescription)
            }
        }
    }
    
    @IBAction func logout(_ sender: UIButton) {
        Task {
            await displayLogoutAlert()
        }
    }
    
    @IBAction func clearLog(_ sender: UIButton) {
        logTextView.text = ""
    }
}

extension DashboardViewController {
    
    func configureUI() {
        logTextView.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        logTextView.layer.borderWidth = 1.0
        logTextView.alwaysBounceVertical = true
        logTextView.textContainer.lineBreakMode = .byCharWrapping
        logTextView.text = ""
        
        accessTokenTextView.delegate = self
        refreshTokenTextView.delegate = self
    }
    
    func displayLogoutAlert() async {
        
        let logoutAlert = viewModel.getLogoutOptionsAlert()
        present(logoutAlert, animated: true)
    }
}

extension DashboardViewController: BaseViewControllerDelegate {
    
    func stateChanged(_ isLoading: Bool?) {
        
        if let isLoading = isLoading {
            self.setActivityIndicator(isLoading)
        }
        
        DispatchQueue.main.async {
            
            self.tokenRequestStackView.isHidden = self.viewModel.isTokenRequestStackViewHidden
            self.codeExchangeButton.isHidden = !self.viewModel.isCodeExchangeRequired
            self.refreshTokenButton.isHidden = !self.viewModel.isTokenActive
            self.userinfoButton.isHidden = !self.viewModel.isTokenActive
            self.profileButton.isHidden = !self.viewModel.isBrowserSessionActive
            self.tokenDataStackView.isHidden = self.viewModel.isTokenDataStackViewHidden
            
            if !self.tokenDataStackView.isHidden {
                self.accessTokenTextView.text = self.viewModel.lastAccessTokenResponse
                self.accessTokenTitleLabel.text = self.viewModel.isAccessTokenRevoked ? "Access Token Revoked:" : "Access Token:"
                self.refreshTokenTextView.text = self.viewModel.lastRefreshTokenResponse
                self.refreshTokenTitleLabel.text = self.viewModel.isRefreshTokenRevoked ? "Refresh Token Revoked:" : "Refresh Token:"
            }
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


//MARK: TextViewDelegate
extension DashboardViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedRange = NSMakeRange(0, textView.text.count)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        accessTokenTextView.endEditing(true)
        refreshTokenTextView.endEditing(true)
    }
}
