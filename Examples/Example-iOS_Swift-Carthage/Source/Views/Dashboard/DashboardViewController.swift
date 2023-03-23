//
//  DashboardViewController.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

@MainActor
class DashboardViewController: BaseViewController {
    
    @IBOutlet private(set) weak var tokenRequestStackView: UIStackView!
    @IBOutlet private(set) weak var codeExchangeButton: UIButton!
    @IBOutlet private(set) weak var userinfoButton: UIButton!
    @IBOutlet private(set) weak var refreshTokenButton: UIButton!
    @IBOutlet private(set) weak var browserButton: UIButton!
    @IBOutlet private(set) weak var profileButton: UIButton!
    @IBOutlet private(set) weak var logTextView: UITextView!
    @IBOutlet private(set) weak var tokenDataStackView: UIStackView!
    @IBOutlet private(set) weak var accessTokenTitleLabel: UILabel!
    @IBOutlet private(set) weak var refreshTokenTitleLabel: UILabel!
    @IBOutlet private(set) weak var accessTokenTextView: UITextView!
    @IBOutlet private(set) weak var refreshTokenTextView: UITextView!
    @IBOutlet private(set) weak var accessTokenStackView: UIStackView!
    @IBOutlet private(set) weak var refreshTokenStackView: UIStackView!
    
    var viewModel: DashboardViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        discoverConfig()
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
            
            setActivityIndicator(false)
            updateUI()
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
            
            setActivityIndicator(false)
            updateUI()
        }
    }
    
    @IBAction func userinfo(_ sender: UIButton) {
        Task {
            setActivityIndicator(true)
            
            do {
                let userInfo = try await viewModel.getUserInfo()
                printToLogTextView(userInfo)
            } catch let error as AuthError {
                displayAlert(error: error)
                printToLogTextView(error.errorUserInfo.debugDescription)
            } catch {
                printToLogTextView(error.localizedDescription)
            }
            
            setActivityIndicator(false)
            updateUI()
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
            
            setActivityIndicator(false)
            updateUI()
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
            
            setActivityIndicator(false)
            updateUI()
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
            updateUI()
        }
    }
    
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
        setActivityIndicator(true)
        
        let logoutAlert = viewModel.getLogoutOptionsAlert() { result in
            switch result {
            case .success(let completed):
                let logoutCompleted = completed ? "Success" : "Failure"
                print("Logout \(logoutCompleted)")
            case .failure(let error as AuthError):
                self.displayErrorAlert(error)
            case .failure:
                self.displayErrorAlert(AuthError.logoutFailed)
            }
            
            self.setActivityIndicator(false)
            self.updateUI()
        }
        present(logoutAlert, animated: true)
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.tokenRequestStackView.isHidden = self.viewModel.isTokenRequestStackViewHidden
            self.codeExchangeButton.isHidden = self.viewModel.isCodeExchangeButtonHidden
            self.refreshTokenButton.isHidden = self.viewModel.isRefreshTokenButtonHidden
            self.userinfoButton.isHidden = self.viewModel.isUserinfoButtonHidden
            self.profileButton.isHidden = self.viewModel.isProfileButtonHidden
            self.tokenDataStackView.isHidden = self.viewModel.isTokenDataStackViewHidden
            
            if !self.tokenDataStackView.isHidden {
                self.accessTokenTitleLabel.text = self.viewModel.accessTokenTitleLabelText
                self.accessTokenTextView.text = self.viewModel.accessTokenTextViewText
                self.refreshTokenTitleLabel.text = self.viewModel.refreshTokenTitleLabelText
                self.refreshTokenTextView.text = self.viewModel.refreshTokenTextViewText
            }
        }
    }
}

extension DashboardViewController: BaseViewControllerDelegate {
    
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
