//
//  DashboardViewController.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

class DashboardViewController: UIViewController {
    
    @IBOutlet private weak var tokenStackView: UIStackView!
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
    
    var viewModel: DashboardViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let metadata = viewModel?.metadata {
            printToLogTextView(metadata)
        } else {
            viewModel?.discoverConfig()
        }
    }
}

//MARK: IBActions
extension DashboardViewController {
    
    @IBAction func checkBrowserSession(_ sender: UIButton) {
        viewModel?.checkBrowserSession()
    }
    
    @IBAction func codeExchange(_ sender: UIButton) {
        viewModel?.manualCodeExchange()
    }
    
    @IBAction func userinfo(_ sender: UIButton) {
        viewModel?.getUserInfo()
    }
    
    @IBAction func refreshToken(_ sender: UIButton) {
        viewModel?.refreshTokens()
    }
    
    @IBAction func profileManagement(_ sender: UIButton) {
        viewModel?.loadProfileManagement()
    }
    
    @IBAction func logout(_ sender: UIButton) {
        //displayLogoutAlert()
        displayLogoutAlert()
    }
    
    @IBAction func clearLog(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.logTextView.text = ""
        }
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
    
    func updateUI() {
        authStateChanged()
    }
    
    func printToLogTextView(_ data: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        
        // appends to output log
        DispatchQueue.main.async {
            let logText = "\(self.logTextView.text ?? "")\n\(dateString): \(data)"
            self.logTextView.text = logText
            
            let range = NSMakeRange(self.logTextView.text.count - 1, 0)
            self.logTextView.scrollRangeToVisible(range)
        }
    }
    
    func authStateChanged() {

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                
                self.tokenStackView.isHidden = self.viewModel?.isTokenDataHidden ?? false
                
                self.profileButton.isHidden = self.viewModel?.isProfileManagementDisabled ?? false
                
                self.codeExchangeButton.isHidden = !(self.viewModel?.isCodeExchangeRequired ?? false)
                self.refreshTokenButton.isHidden = !(self.viewModel?.isTokenRefreshEnabled ?? false)
                self.userinfoButton.isHidden = !(self.viewModel?.isGetUserInfoEnabled ?? false)
                
                self.tokenDataStackView.isHidden = self.viewModel?.isTokenDataHidden ?? false
                if !self.tokenDataStackView.isHidden {
                    let isTokenActive = self.viewModel?.isTokenActive ?? false
                    self.accessTokenTextView.text = self.viewModel?.lastAccessTokenResponse
                    self.accessTokenTitleLabel.text = isTokenActive ? "Access Token:" : "Access Token Revoked:"
                    self.refreshTokenTextView.text = self.viewModel?.lastRefreshTokenResponse
                    self.refreshTokenTitleLabel.text = isTokenActive ? "Refresh Token:" : "Refresh Token Revoked:"
                }
            }
        }
    }
    
    func displayLogoutAlert() {
        
        guard let logoutAlert = viewModel?.getLogoutOptionsAlert() else {
            printToLogTextView("Logout options failed to load.")
            return
        }
        
        DispatchQueue.main.async {
            self.present(logoutAlert, animated: true, completion: nil)
        }
    }
    
    func handleLogoutSelections(_ logoutSelections: Set<LogoutType>) {
        viewModel?.handleLogoutSelections(logoutSelections)
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
