//
//  WebServiceManagerTests.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//
import XCTest
import Foundation
import UIKit
@testable import AppAuth
@testable import Example

class WebServiceManagerTests: XCTestCase {
        
    var sut: WebServiceManager!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        super.setUp()
        
        sut = WebServiceManager()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        
        super.tearDown()
    }
    
    func testAuthState() {
        
    }
}
