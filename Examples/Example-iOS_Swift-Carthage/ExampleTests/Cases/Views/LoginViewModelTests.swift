//
//  LoginViewModelTests.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import XCTest
import Foundation
import UIKit
@testable import AppAuth
@testable import Example

@MainActor
class LoginViewModelTests: XCTestCase {
    
    var navigationController: UINavigationController!
    var authenticator: Authenticator!
    var viewModel: LoginViewModel!
    var baseViewControllerDelegateMock: MockBaseViewControllerDelegate!
    var viewCoordinatorDelegateMock: MockCoordinatorDelegate!
    
    override func setUp() {
        super.setUp()
        
        navigationController = UINavigationController()
        authenticator = Authenticator(navigationController)
        viewModel = LoginViewModel(authenticator)
        
        baseViewControllerDelegateMock = MockBaseViewControllerDelegate()
        viewModel.viewControllerDelegate = baseViewControllerDelegateMock
        
        viewCoordinatorDelegateMock = MockCoordinatorDelegate()
        viewModel.coordinatorDelegate = viewCoordinatorDelegateMock
    }
    
    override func tearDown() {
        viewModel = nil
        authenticator = nil
        navigationController = nil
        baseViewControllerDelegateMock = nil
        viewCoordinatorDelegateMock = nil
        
        super.tearDown()
    }
    
    func testDiscoverConfiguration() async throws {
        let expectation = self.expectation(description: "Expected to discover configuration")
        
        try await viewModel.discoverConfiguration()
        
        XCTAssertNotNil(viewModel.discoveryConfig)
        XCTAssertTrue(baseViewControllerDelegateMock.printedText.contains("mockDiscoveryConfig"))
        
        expectation.fulfill()
        wait(for: [expectation], timeout: 1)
    }
    
    func testBeginBrowserAuthenticationWithAutoCodeExchange() async throws {
        let expectation = self.expectation(description: "Expected to authenticate with auto code exchange")
        
        viewModel.isManualCodeExchange = false
        
        try await viewModel.beginBrowserAuthentication()
        
        XCTAssertNotNil(AppDelegate.shared.currentAuthorizationFlow)
        XCTAssertTrue(baseViewControllerDelegateMock.stateChangeCalled ?? false)
        XCTAssertTrue(viewCoordinatorDelegateMock.loginSucceededCalled ?? false)
        
        expectation.fulfill()
        wait(for: [expectation], timeout: 1)
    }
    
    func testBeginBrowserAuthenticationWithManualCodeExchange() async throws {
        let expectation = self.expectation(description: "Expected to authenticate with manual code exchange")
        
        viewModel.isManualCodeExchange = true
        
        try await viewModel.beginBrowserAuthentication()
        
        XCTAssertNotNil(AppDelegate.shared.currentAuthorizationFlow)
        XCTAssertTrue(baseViewControllerDelegateMock.stateChangeCalled ?? false)
        XCTAssertTrue(viewCoordinatorDelegateMock.loginSucceededCalled ?? false)
        
        expectation.fulfill()
        wait(for: [expectation], timeout: 1)
    }
}

class MockCoordinatorDelegate: LoginViewModelCoordinatorDelegate {
    var loginSucceededCalled: Bool?
    
    func loginSucceeded(with authenticator: Example.Authenticator) {
        loginSucceededCalled = authenticator.isAuthStateActive
    }
}

class MockBaseViewControllerDelegate: BaseViewControllerDelegate {
    
    var printedText = ""
    var stateChangeCalled: Bool?
    var errorAlertDisplayed: Bool?
    
    func stateChanged(_ isLoading: Bool?) {
        stateChangeCalled = true
    }
    
    func printToLogTextView(_ data: String) {
        printedText = data
    }
    
    func displayErrorAlert(_ error: Example.AuthError?) {
        errorAlertDisplayed = true
    }
    
    func displayAlertWithAction(_ error: Example.AuthError?, alertAction: AlertAction) {
        
    }
}
