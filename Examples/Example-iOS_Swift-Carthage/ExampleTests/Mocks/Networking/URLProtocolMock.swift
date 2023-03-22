//
//  URLProtocolMock.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All rights reserved.
//


import Foundation
@testable import Example

class URLProtocolMock: URLProtocol {
    
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        // Check if this protocol can handle the given request.
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Return the canonical version of the request.
        return request
    }
    
    override func startLoading() {
        guard let handler = URLProtocolMock.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            let (response, data) = try handler(request)
            
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        // This is called if the request gets canceled or completed.
    }
}
