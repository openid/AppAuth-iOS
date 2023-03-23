//
//  DashboardViewModelTests.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import XCTest
import Foundation
import UIKit
import AppAuth
@testable import Example

@MainActor
class DashboardViewModelTests: XCTestCase {
    
    var sut: DashboardViewModel!
    
    var authenticatorMock: AuthenticatorMock!
    var authConfigMock: AuthConfigMock!
    var appAuthMocks: AppAuthMocks!
    var viewCoordinatorDelegateMock: DashboardViewModelCoordinatorDelegateMock!
    
    override func setUp() {
        super.setUp()
        
        authConfigMock = AuthConfigMock()
        authenticatorMock = AuthenticatorMock()
        
        sut = DashboardViewModel(authenticatorMock)
        
        viewCoordinatorDelegateMock = DashboardViewModelCoordinatorDelegateMock()
        sut.coordinatorDelegate = viewCoordinatorDelegateMock
        appAuthMocks = AppAuthMocks()
    }
    
    override func tearDown() {
        sut = nil
        viewCoordinatorDelegateMock = nil
        authenticatorMock = nil
        appAuthMocks = nil
        authConfigMock = nil
        AppDelegate.shared.currentAuthorizationFlow = nil
        
        super.tearDown()
    }
    
    func testViewModelExists() {
        // Make sure the AuthStateManager was initialized
        XCTAssertNotNil(sut)
    }
}
