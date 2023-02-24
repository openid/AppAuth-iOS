//
//  WebServiceManager.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import UIKit
import AppAuth

class WebServiceManager {
    
    /*
     * Sends a predefined URL request and handles common errors.
     */
    static func sendUrlRequest(_ request: URLRequest) async throws -> (Data?, String?) {
        
        // Send the request and get the response
        do {

            let (data, response) = try await URLSession.shared.data(for: request)

            // Get the response as an HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {

                throw AuthError.api(message: "Invalid HTTP response object received after an API call", underlyingError: nil)
            }

            // Check for a successful status
            if httpResponse.statusCode < 200 || httpResponse.statusCode > 299 {
                throw AuthError.api(message: httpResponse.description, underlyingError: nil)
            }
            
            if let responseJson = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers), let responseData = try? JSONSerialization.data(withJSONObject: responseJson, options: .prettyPrinted) {
                
                let responseString = String(data: responseData, encoding: .utf8)
                
                // Returns response data and response string on success
                return (responseData, responseString)
            }

            // Return the response data on success
            return (data, nil)

        } catch {
            throw AuthError.api(message: error.localizedDescription, underlyingError: error)
        }
    }
}
