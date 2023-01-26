//
//  WebServiceManager.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import UIKit
import AppAuth

protocol WebServiceManagerProtocol {
    
    typealias CompletionUrlRequest = (Result<(Data?, HTTPURLResponse?), AuthError>) -> Void
    
    func sendUrlRequest(_ urlRequest: URLRequest, _ completion: @escaping CompletionUrlRequest)
}

class WebServiceManager: WebServiceManagerProtocol {
    
    /**
     Sends a URL request.
     
     Sends a predefined request and handles common errors.
     
     - Parameter urlRequest: URLRequest optionally crafted with additional information, which may include access token.
     - Parameter completion: Escaping completion handler allowing the caller to process the response.
     */
    func sendUrlRequest(_ urlRequest: URLRequest, _ completion: @escaping CompletionUrlRequest) {
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            let response = response as? HTTPURLResponse
            
            guard error == nil else {
                let authError = AuthError(.apiResponseError, error: error, data: data, response: response)
                completion(.failure(authError))
                return
            }
            
            guard let data = data, data.count > 0 else {
                completion(.failure(AuthError(.apiResponseEmptyError, error: error, data: data, response: response)))
                return
            }
            
            if let response = response, response.statusCode != 200 {
                // Server replied with an error
                let responseText: String? = String(data: data, encoding: String.Encoding.utf8)
                
                if response.statusCode == 401 {
                    // "401 Unauthorized" generally indicates there is an issue with the authorization grant; hence, putting OIDAuthState into an error state.
                    
                    print("Authorization Error (\(error.debugDescription)). Response: \(responseText.debugDescription)")
                    
                    completion(.failure(AuthError(.apiResponseError, error: error, statusCode: response.statusCode, data: data, response: response)))
                    
                } else {
                    
                    print("HTTP: \(response.statusCode), Response: \(responseText ?? "")")
                    
                    completion(.failure(AuthError(.apiResponseError, error: error, statusCode: response.statusCode, data: data, response: response)))
                }
            }
            
            DispatchQueue.main.async {
                completion(.success((data, response)))
            }
        }
        
        task.resume()
    }
}
