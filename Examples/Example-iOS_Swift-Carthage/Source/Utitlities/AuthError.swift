//
//  AppAuthError.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit
import AppAuth

/*
 * An error entity whose fields are rendered when there is a problem
 */
enum ErrorType: String, LocalizedError {
    
    // A general exception
    case generalError = "An error occured. Check the log for details"
    
    // A general exception in the UI
    case generalUIError = "The requested interface failed to load"
    
    // A problem loading configuration
    case configurationError = "An error occured within the discovery configuration"
    
    // A problem loading configuration
    case configurationLoadingError = "An error occured loading the discovery configuration"
    
    // Used to indicate that the API cannot be called until the user logs in
    case loginRequired = "A login is required so the API call was aborted"
    
    // Used to indicaten that the Safari View Controller was cancelled
    case redirectCancelled = "The redirect request was cancelled"
    
    // A technical error starting a login request, such as contacting the metadata endpoint
    case loginRequestFailed = "A technical problem occurred during the login request"
    
    // A technical error starting a profile management request
    case profileManagementRequestFailed = "A technical problem occurred loading profile management"
    
    // A technical error processing the login response containing the authorization code
    case loginResponseFailed = "A technical problem occurred process the login response"
    
    // A technical error refreshing tokens
    case refreshTokenGrantFailed = "An error occured refreshing tokens"
    
    // A technical error revoking access token
    case accessTokenRevokeFailed = "An error occured revoking the access token"
    
    // A technical error revoking refresh token
    case refreshTokenRevokeFailed = "An error occured revoking the refresh token"
    
    // A technical error exchanging the authorization code
    case codeExchangeFailed = "A technical problem occurred during the code exchange"
    
    // A technical error with the user info response
    case userInfoResponseFailed = "An error occured processing the user info response"
    
    // A technical error with the user info request
    case userInfoRequestFailed = "An error occured requesting the user info"
    
    // A technical error during a logout redirect
    case logoutRequestFailed = "A technical problem occurred during logout processing"
    
    // A technical error occured parsing the response
    case responseParsingFailed = "An error occured parsing the reponse data"
    
    // An error making an API call to get data
    case apiNetworkError = "A network problem occurred calling the server"
    
    // An error response from the API
    case apiResponseError = "A technical problem occurred processing the server response"
    
    // An error from the api response with an empty body
    case apiResponseEmptyError = "The an empty response body was returned for the request"
    
    // The access token has either expired or isn't stored locally
    case accessTokenError = "Access token has expired or does not exist. Re-Authentication required."
    
    // The refresh token has either expired or isn't stored locally
    case refreshTokenError = "Refresh token has expired or does not exist. Re-Authentication required."
    
    // Token have either expired or are not stored locally
    case tokenError = "Tokens have expired or do not exist. Re-Authentication required."
    
    // An error occured initializing the authentication manager
    case authManagerLoadingError = "Error loading the authentication manager"
    
    // An authorization error occured within the OIDAuthState
    case authStateError = "An authorization error occured"
    
    var errorDescription: String? {
        self.rawValue
    }
}

struct AuthError: Error {
    var errorType: ErrorType
    var error: Error?
    var userMessage: String?
    var details: String?
    var statusCode: Int?
    var errorCode: Int?
    var data: Data?
    var tokenType: TokenType?
    
    var response: HTTPURLResponse? {
        didSet {
            statusCode = response?.statusCode
        }
    }
    
    init(_ errorType: ErrorType = .generalError, error: Error? = nil, userMessage: String? = nil, details: String? = nil, statusCode: Int? = nil, data: Data? = nil, response: HTTPURLResponse? = nil, _ tokenType: TokenType? = nil) {
        self.errorType = errorType
        self.error = error
        self.userMessage = userMessage
        self.details = details
        self.statusCode = statusCode
        self.data = data
        self.response = response
        self.tokenType = tokenType
        
        if self.tokenType != nil {
            switch self.tokenType {
            case .accessToken:
                self.errorType = .accessTokenError
            case .refreshToken:
                self.errorType = .refreshTokenError
            case .none:
                break
            }
        }
        
        if let data = self.data {
            updateFromApiErrorResponse(responseData: data)
        }
        
        if let error = self.error {
            updateFromException(error: error)
        }
        
        if self.userMessage == nil {
            self.userMessage = self.errorType.errorDescription
        }
    }
}

extension AuthError {
    
    /*
     * Add iOS details from the exception
     */
    private mutating func updateFromException(error: Error) {
        
        let nsError = error as NSError
        var details = error.localizedDescription
        
        // Get iOS common details
        if nsError.domain.count > 0 {
            details += "\nDomain: \(nsError.domain)"
        }
        if nsError.code != 0 {
            details += "\nCode: \(nsError.code)"
            self.errorCode = nsError.code
        }
        for (name, value) in nsError.userInfo {
            details += "\n\(name): \(value)"
        }
        
        switch nsError.code {
        case OIDErrorCode.userCanceledAuthorizationFlow.rawValue:
            self.errorType = .redirectCancelled
        default:
            break
        }
        
        self.details = details
    }
    
    /*
     * Try to update the default API error with response details
     */
    private mutating func updateFromApiErrorResponse(responseData: Data) {
        
        var json: [AnyHashable: Any]?
        
        if let json = try? JSONSerialization.jsonObject(with: responseData, options: []) {
            
            if let fields = json as? [String: Any] {
                
                // Read standard fields that the API returns
                if let errorCode = fields["code"] as? Int {
                    self.errorCode = errorCode
                }
                if let errorMessage = fields["message"] as? String {
                    self.userMessage = errorMessage
                }
            }
        }
        
        if self.statusCode == 401 {
            let currentError = self.error
            self.error = OIDErrorUtilities.resourceServerAuthorizationError(withCode: 0,
                                                                            errorResponse: json,
                                                                            underlyingError: currentError)
        }
    }
}
