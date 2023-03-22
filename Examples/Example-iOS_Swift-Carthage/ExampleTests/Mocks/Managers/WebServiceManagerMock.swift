//
//  WebServiceManagerMock.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All rights reserved.
//


import Foundation
@testable import Example

// MARK: - WebServiceManagerMock -

class WebServiceManagerMock: WebServiceManagerProtocol {
    
    // MARK: - urlSession
    
    init(_ urlSession: URLSessionProtocol) {
        self.urlSession = urlSession
    }
    
    var urlSession: URLSessionProtocol {
        get { underlyingUrlSession }
        set(value) { underlyingUrlSession = value }
    }
    private var underlyingUrlSession: URLSessionProtocol!
    
    // MARK: - sendUrlRequest
    
    var sendUrlRequestThrowableError: Error?
    var sendUrlRequestCallsCount = 0
    var sendUrlRequestCalled: Bool {
        sendUrlRequestCallsCount > 0
    }
    var sendUrlRequestReceivedRequest: URLRequest?
    var sendUrlRequestReceivedInvocations: [URLRequest] = []
    var sendUrlRequestReturnValue: Data!
    var sendUrlRequestClosure: ((URLRequest) throws -> Data)?
    
    func sendUrlRequest(_ request: URLRequest) throws -> Data {
        if let error = sendUrlRequestThrowableError {
            throw error
        }
        sendUrlRequestCallsCount += 1
        sendUrlRequestReceivedRequest = request
        sendUrlRequestReceivedInvocations.append(request)
        return try sendUrlRequestClosure.map({ try $0(request) }) ?? sendUrlRequestReturnValue
    }
    
    // MARK: - getStringFromResponse
    
    var getStringFromResponseThrowableError: Error?
    var getStringFromResponseCallsCount = 0
    var getStringFromResponseCalled: Bool {
        getStringFromResponseCallsCount > 0
    }
    var getStringFromResponseReceivedData: Data?
    var getStringFromResponseReceivedInvocations: [Data] = []
    var getStringFromResponseReturnValue: String?
    var getStringFromResponseClosure: ((Data) throws -> String?)?
    
    func getStringFromResponse(_ data: Data) throws -> String? {
        if let error = getStringFromResponseThrowableError {
            throw error
        }
        getStringFromResponseCallsCount += 1
        getStringFromResponseReceivedData = data
        getStringFromResponseReceivedInvocations.append(data)
        return try getStringFromResponseClosure.map({ try $0(data) }) ?? getStringFromResponseReturnValue
    }
}
