//
//  AppCoordinatorTests.swift
//  ExampleTests
//
//  Created by Michael Moore on 1/27/23.
//  Copyright © 2023 Google Inc. All rights reserved.
//

import XCTest
import Foundation
import UIKit
@testable import AppAuth
@testable import Example

class AppCoordinatorTests: XCTestCase {
        
    var sut: AppCoordinator!
    var window: UIWindow!
    
    @MainActor
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        super.setUp()
        
        window = UIWindow()
        sut = AppCoordinator(window: window)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        window = nil
        
        super.tearDown()
    }
    
    func testAuthState() {
        
        // Make sure the AuthStateManager was initialized
        //XCTAssertNotNil(sut.authStateManager)
    }
}
