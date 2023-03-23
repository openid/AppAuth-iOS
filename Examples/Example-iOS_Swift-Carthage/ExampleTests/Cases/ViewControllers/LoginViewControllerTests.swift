//
//  LoginViewControllerTests.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import XCTest
import Foundation
import UIKit
import AppAuth
@testable import Example

/*
 * Provides tests for the LoginViewController
 */
@MainActor
class LoginViewControllerTests: XCTestCase {
    
    var sut: LoginViewController!
    
    var loginViewModelMock: LoginViewModelMock!
    var authenticatorMock: AuthenticatorMock!
    var authConfigMock: AuthConfigMock!
    var appAuthMocks: AppAuthMocks!
    
    override func setUp() {
        super.setUp()
        
        authConfigMock = AuthConfigMock()
        authenticatorMock = AuthenticatorMock()
        appAuthMocks = AppAuthMocks()
        
        loginViewModelMock = LoginViewModelMock(authenticatorMock)
        let discoveryConfig = appAuthMocks.loadMockServiceConfig(issuer: authConfigMock.discoveryUrl)
        loginViewModelMock.discoverConfigurationReturnValue = discoveryConfig.description
        
        sut = LoginViewController.instantiate(from: .Main)
        sut.viewModel = loginViewModelMock
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        
        sut = nil
        loginViewModelMock = nil
        authenticatorMock = nil
        authConfigMock = nil
        appAuthMocks = nil
        
        super.tearDown()
    }
    
    /*
     * Checks if required custom URI schemehas been set.
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
        
        XCTAssertEqual(urlScheme, authConfigMock.redirectUriScheme, "The URI scheme in the Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0) does not match one used in the redirect URI, where the scheme is everything before the colon (:)."
        )
        
        XCTAssertNotNil(authConfigMock.redirectUrl)
        XCTAssertNotNil(authConfigMock.redirectUrl.host)
    }
    
    /*
     * Checks if the LoginViewController ViewModel is set
     */
    func testLoginViewModelExists() {
        
        guard let _ = sut else {
            XCTFail("Login view controller is not present.")
            
            return
        }
        
        XCTAssertNotNil(loginViewModelMock, "There should be a ViewModel available")
    }
    
    func testLoadDiscoveryDocCalled() {
        let requestExpectation = XCTestExpectation(description: "Request Expectation")
        
        loginViewModelMock.discoverConfigurationClosure = {
            requestExpectation.fulfill()
            return self.loginViewModelMock.discoverConfigurationReturnValue
        }
        
        wait(for: [requestExpectation], timeout: 10.0)
        XCTAssertTrue(loginViewModelMock.discoverConfigurationCalled)
    }
    
    func testCodeExchangeSelectionDefaultsToAuto() {
        XCTAssertFalse(loginViewModelMock.isManualCodeExchange)
    }
    
    func testCodeExchangeChangesToManualUponSelection() throws {
        
        // Given: The auth type selected is manual code exchange
        let segmentedControl = try XCTUnwrap(sut.authTypeSegementedControl)
        segmentedControl.selectedSegmentIndex = 1
        sut.authTypeSelectionChanged(segmentedControl)
        
        let authExpectation = XCTestExpectation(description: "Authentication Expectation")
        loginViewModelMock.beginBrowserAuthenticationClosure = {
            authExpectation.fulfill()
        }
        
        sut.authButton.sendActions(for: .touchUpInside)
        
        wait(for: [authExpectation], timeout: 10.0)
        XCTAssertTrue(loginViewModelMock.beginBrowserAuthenticationCalled)
        XCTAssertTrue(try XCTUnwrap(loginViewModelMock.setManualCodeExchangeReceivedIsSelected))
    }
    
    func testAutoCodeExchangeAuthTypeIsSelectedAndSucceeds() throws {
        
        // Given: Auto code exchange authorization type is selected
        let segmentedControl = try XCTUnwrap(sut.authTypeSegementedControl)
        segmentedControl.selectedSegmentIndex = 0
        sut.authTypeSelectionChanged(segmentedControl)
        
        let authExpectation = XCTestExpectation(description: "Authentication Expectation")
        
        loginViewModelMock.beginBrowserAuthenticationClosure = {
            authExpectation.fulfill()
        }
        
        // When: The authorization process is initiated
        sut.authButton.sendActions(for: .touchUpInside)
        
        // Then: Auto code authorization is executed
        XCTWaiter().wait(for: [authExpectation], timeout: 10.0)
        XCTAssertTrue(loginViewModelMock.beginBrowserAuthenticationCalled)
        XCTAssertFalse(try XCTUnwrap(loginViewModelMock.setManualCodeExchangeReceivedIsSelected))
    }
    
    func testPrintToLogTextViewOutputsText() {
        sut.printToLogTextView("Log text")
        
        XCTAssertNotNil(sut.logTextView.text, "Logging to the text view failed")
    }
}
