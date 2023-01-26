//
//  LoginViewController.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet private weak var authButton: UIButton!
    @IBOutlet weak var authTypeSegementedControl: UISegmentedControl!
    @IBOutlet private weak var logTextView: UITextView!
    
    var viewModel: LoginViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let metadata = viewModel?.metadata {
            printToLogTextView(metadata)
        } else {
            viewModel?.discoverConfig()
        }
    }
}

//MARK: IBActions
extension LoginViewController {
    
    @IBAction func authorizeUser(_ sender: UIButton) {
        
        viewModel?.onTapLogin()
    }
    
    @IBAction func authTypeSelectionChanged(_ sender: UISegmentedControl) {
        
        viewModel?.isManualCodeExchange = sender.selectedSegmentIndex == 1
    }
    
    @IBAction func clearLog(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.logTextView.text = ""
        }
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
    
    func updateUI() {
        authButton.isEnabled = !(viewModel?.isLoading ?? false)
        authTypeSegementedControl.isEnabled = !(viewModel?.isLoading ?? false)
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
}
