//
//  WebServiceManagerTests.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//
import XCTest
import Foundation
import UIKit
import AppAuth
@testable import Example

class WebServiceManagerTests: XCTestCase {
    
    var sut: WebServiceManager!
    
    var authenticatorMock: AuthenticatorMock!
    var authRequestFactoryMock: AuthRequestFactoryProtocol!
    var appAuthMocks: AppAuthMocks!
    var authConfigMock: AuthConfigMock!
    let testURL = URL(string: "https://example.com")!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        let urlSession = URLSession.init(configuration: configuration)
        
        sut = WebServiceManager(urlSession)
        authConfigMock = AuthConfigMock()
        authenticatorMock = AuthenticatorMock()
        appAuthMocks = AppAuthMocks()
        authRequestFactoryMock = AuthRequestFactory(authConfigMock)
    }
    
    override func tearDown() {
        sut = nil
        authenticatorMock = nil
        authRequestFactoryMock = nil
        appAuthMocks = nil
        authConfigMock = nil
        
        super.tearDown()
    }
    
    func testUrlRequestResponseDataReceived() async throws {
        let token = appAuthMocks.mockAccessToken
        let request = authRequestFactoryMock.revokeTokenRequest(token)
        
        // Prepare mock response.
        
        let responseData = appAuthMocks.getTokenResponseData()
        
        URLProtocolMock.requestHandler = { request in
            guard let url = request.url else {
                throw AuthError.api(message: "Refresh token request url not found", underlyingError: nil)
            }
            
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        do {
            let response = try await sut.sendUrlRequest(XCTUnwrap(request))
            XCTAssertNotNil(response)
        } catch {
            XCTFail("Expected to succeed while awaiting, but failed.")
        }
    }
    
    func testUrlRequestErrorThrown() async throws {
        let request = authRequestFactoryMock.revokeTokenRequest("/")
        
        var responseError: Error? = nil
        
        do {
            let _ = try await sut.sendUrlRequest(try XCTUnwrap(request))
        } catch {
            responseError = error
            XCTAssertNotNil(responseError)
        }
    }
    
    func testResponseServerErrorIsThrown() async throws {
        
        let urlRequest = URLRequest(url: testURL)
        
        URLProtocolMock.requestHandler = { request in
            
            let responseData = Data()
            let response = HTTPURLResponse(url: urlRequest.url!, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
        
        do {
            let _ = try await sut.sendUrlRequest(urlRequest)
            XCTFail("Expected to fail while awaiting, but succeeded.")
        } catch let error as AuthError {
            XCTAssertEqual(error.errorCode, 400)
        }
    }
}
