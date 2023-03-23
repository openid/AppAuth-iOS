//
//  DashboardViewControllerTests.swift
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
 * Provides tests for the DashboardViewController
 */
@MainActor
class DashboardViewControllerTests: XCTestCase {
    
    var sut: DashboardViewController!
    
    var dashboardViewModelMock: DashboardViewModelMock!
    var authenticatorMock: AuthenticatorMock!
    var authConfigMock: AuthConfigMock!
    var appAuthMocks: AppAuthMocks!
    
    override func setUp() {
        super.setUp()
        
        authConfigMock = AuthConfigMock()
        authenticatorMock = AuthenticatorMock()
        appAuthMocks = AppAuthMocks()
        
        dashboardViewModelMock = DashboardViewModelMock(authenticatorMock)
        let discoveryConfig = appAuthMocks.loadMockServiceConfig(issuer: authConfigMock.discoveryUrl)
        dashboardViewModelMock.discoverConfigurationReturnValue = discoveryConfig.description
        
        sut = DashboardViewController.instantiate(from: .Main)
        sut.viewModel = dashboardViewModelMock
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        
        sut = nil
        dashboardViewModelMock = nil
        authenticatorMock = nil
        authConfigMock = nil
        appAuthMocks = nil
        
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
        
        XCTAssertEqual(urlScheme, authConfigMock.redirectUriScheme, "The URI scheme in the Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0) does not match one used in the redirect URI, where the scheme is everything before the colon (:)."
        )
        
        XCTAssertNotNil(authConfigMock.redirectUrl)
        XCTAssertNotNil(authConfigMock.redirectUrl.host)
    }
    
    /*
     * Checks if the DashboardViewController ViewModel is set
     */
    func testDashboardViewModelExists() {
        
        guard let _ = sut else {
            XCTFail("Dashboard view controller is not present.")
            
            return
        }
        
        XCTAssertNotNil(dashboardViewModelMock, "There should be a ViewModel available")
    }
}
