//
//  LoginViewControllerTests.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import XCTest
import Foundation
import UIKit
@testable import AppAuth
@testable import Example

/*
 * Provides tests for the LoginViewController
 */
@MainActor
class LoginViewControllerTests: XCTestCase {
    var navigationController: UINavigationController!
    var storyboard: UIStoryboard!
    var sut: LoginViewController!
    var loginViewModel: LoginViewModel!
    var authenticator: Authenticator!
    
    override func setUp() {
        super.setUp()
        
        navigationController = UINavigationController()
        authenticator = Authenticator(navigationController)
        
        sut = LoginViewController.instantiate(from: .Main)
        loginViewModel = LoginViewModel(authenticator)
        sut.viewModel = loginViewModel
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        
        navigationController = nil
        storyboard = nil
        sut = nil
        loginViewModel = nil
        authenticator = nil
        
        super.tearDown()
    }
    
    /*
     * Checks if custom URI scheme is necessary and has been set.
     */
    func testUriScheme() {
        
        let noPrivateUseUriScheme = "No private-use URI scheme has been configured for the project."
        
        guard let urlTypes: [AnyObject] = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [AnyObject], urlTypes.count > 0 else {
            XCTFail(noPrivateUseUriScheme)
            
            return
        }
        
        guard let items = urlTypes[0] as? [String: AnyObject], let urlSchemes = items["CFBundleURLSchemes"] as? [AnyObject], urlSchemes.count > 0 else {
            XCTFail(noPrivateUseUriScheme)
            
            return
        }
        
        guard let urlScheme = urlSchemes[0] as? String else {
            XCTFail(noPrivateUseUriScheme)
            
            return
        }
        
        XCTAssertEqual(urlScheme, AuthConfig.redirectUriScheme, "The URI scheme in the Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0) does not match one used in the redirect URI, where the scheme is everything before the colon (:)."
        )
        
        XCTAssertNotNil(AuthConfig.redirectUrl)
        XCTAssertNotNil(AuthConfig.redirectUrl.host)
    }
    
    /*
     * Checks if the LoginViewController ViewModel is set
     */
    func testLoginViewModelExists() {
        
        guard let _ = sut else {
            XCTFail("Login view controller is not present.")
            
            return
        }
        
        XCTAssertNotNil(loginViewModel, "There should be a ViewModel available")
    }
    
    func testDiscoveryDocLoadedAndLogged() async throws {
        try await authenticator.getDiscoveryConfig(AuthConfig.discoveryUrl)
        sut.viewDidLoad()
        
        XCTAssertNotNil(sut.logTextView.text)
    }
    
    func testCodeExchangeSelectionDefaultsToAuto() {
        XCTAssertEqual(loginViewModel.isManualCodeExchange, false)
    }
    
    func testCodeExchangeChangesToManualUponSelection() {
        let segmentedControl = sut.authTypeSegementedControl!
        segmentedControl.selectedSegmentIndex = 1
        sut.authTypeSelectionChanged(segmentedControl)
        
        XCTAssertEqual(loginViewModel.isManualCodeExchange, true)
    }
    
    func testPrintToLogTextViewOutputsText() {
        sut.printToLogTextView("Log text")
        
        XCTAssertNotNil(sut.logTextView.text, "Logging to the text view failed")
    }
}
