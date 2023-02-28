//
//  LoginCoordinatorTests.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import XCTest
import Foundation
import UIKit
@testable import AppAuth
@testable import Example

class LoginCoordinatorTests: XCTestCase {
    var navigationController: UINavigationController!
        
    var sut: LoginCoordinator!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        super.setUp()
        
        navigationController = UINavigationController()
        //sut = LoginCoordinator(navigationController)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        navigationController = nil
        sut = nil
        
        super.tearDown()
    }
    
    func testAuthState() {
        
        // Make sure the AuthStateManager was initialized
        //XCTAssertNotNil(sut.authStateManager)
    }
}
