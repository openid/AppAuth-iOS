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
    var navigationController: UINavigationController!
    var authenticator: Authenticator!
    
    override func setUp() {
        super.setUp()
        
        sut = WebServiceManager()
        navigationController = UINavigationController()
        authenticator = Authenticator(navigationController)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        
        super.tearDown()
    }
    
    func testUrlRequestResponseDataReceived() async throws {
        try await authenticator.getDiscoveryConfig(AuthConfig.discoveryUrl)
        let token = AppAuthMocks.mockAccessToken
        let request = authenticator.requestFactory.revokeTokenRequest(token)!
        
        var responseError: Error? = nil
        var responseData: Data? = nil
        do {
            let (data, _) = try await WebServiceManager.sendUrlRequest(request)
            responseData = data
        } catch {
            responseError = error
        }
        
        XCTAssertNotNil(responseData)
        XCTAssertNil(responseError)
    }
    
    func testUrlRequestErrorThrown() async throws {
        
        try await authenticator.getDiscoveryConfig(AuthConfig.discoveryUrl)
        let request = authenticator.requestFactory.revokeTokenRequest("")!
        
        var responseError: Error? = nil
        
        do {
            let (_, _) = try await WebServiceManager.sendUrlRequest(request)
        } catch {
            responseError = error
        }
        
        XCTAssertNotNil(responseError)
    }
}
