//
//  WebServiceManager.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import UIKit


// MARK: URLSessionDataTaskProtocol
protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

// MARK: URLSessionProtocol

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession : URLSessionProtocol{}

// MARK: WebServiceManagerProtocol
protocol WebServiceManagerProtocol {
    var urlSession: URLSessionProtocol { get }
    func sendUrlRequest(_ request: URLRequest) async throws -> Data
    func getStringFromResponse(_ data: Data) throws -> String?
}

class WebServiceManager: WebServiceManagerProtocol {
    
    private(set) var urlSession: URLSessionProtocol
    
    init(_ urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    /*
     * Sends a predefined URL request.
     */
    func sendUrlRequest(_ request: URLRequest) async throws -> Data {
        
        // Send the request and return the response
        let (data, response) = try await urlSession.data(for: request)
        
        // Get the response as an HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidHttpResponse
        }
        
        print(httpResponse)
        
        // Check for a successful status
        if httpResponse.statusCode < 200 || httpResponse.statusCode > 299 {
            throw AuthError.api(message: httpResponse.debugDescription, underlyingError: NSError(domain: AuthError.errorDomain, code: httpResponse.statusCode))
        }
        
        return data
    }
    
    func getStringFromResponse(_ data: Data) throws -> String? {
        do {
            let responseJson = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            let responseData = try JSONSerialization.data(withJSONObject: responseJson, options: .prettyPrinted)
            return String(data: responseData, encoding: .utf8)
        } catch {
            throw AuthError.parseFailure
        }
    }
}
