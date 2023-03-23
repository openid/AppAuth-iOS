//
//  AuthError.swift
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
enum AuthError: Error {
    
    case authorization(error: String, description: String?)
    
    // An error making an API call to get data
    case api(message: String, underlyingError: Error?)
    
    case unexpectedAuthCodeResponse(statusCode: Int)
    case errorFetchingFreshTokens
    case redirectServerError(String)
    case missingConfigurationValues
    case noAccessToken
    case noDiscoveryEndpoint
    case noDiscoveryDoc
    case notConfigured
    case noRefreshToken
    case noRevocationEndpoint
    case noTokens
    case noUserInfoEndpoint
    case parseFailure
    case invalidHttpResponse
    case missingIdToken
    case userCancelledAuthorizationFlow
    case unableToGetAuthCode
    case noAuthState
    case externalAgentFailed
    case loginFailed
    case logoutFailed
    
    static var errorDomain: String = "\(Self.self)"
    
    static let generalErrorCode = -1012009
    
    var errorCode: Int {
        switch self {
        case let .api(_, underlyingError):
            return (underlyingError as NSError?)?.code ?? Self.generalErrorCode
            
        case let .unexpectedAuthCodeResponse(statusCode):
            return statusCode
        default:
            return Self.generalErrorCode
        }
    }
    
    var errorUserInfo: [String: Any] {
        var result: [String: Any] = [:]
        result[NSLocalizedDescriptionKey] = errorDescription
        
        switch self {
        case let .api(_, underlyingError):
            result[NSUnderlyingErrorKey] = underlyingError
            return result
        default:
            return result
        }
    }
}

extension AuthError: Equatable {
    public static func == (lhs: AuthError, rhs: AuthError) -> Bool {
        lhs as NSError == rhs as NSError
    }
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .api(message, _):
            return NSLocalizedString(message, comment: "")
        case .errorFetchingFreshTokens:
            return NSLocalizedString("Error fetching fresh tokens. Login requred.", comment: "")
        case .missingConfigurationValues:
            return NSLocalizedString("Could not parse 'issuer', 'clientId', and/or 'redirectUri' plist values.", comment: "")
        case .noAuthState:
            return NSLocalizedString("Missing AuthState. Login required.", comment: "")
        case .noAccessToken:
            return NSLocalizedString("Missing Access token. Login required.", comment: "")
        case .noDiscoveryEndpoint:
            return NSLocalizedString("Error finding the well-known OpenID Configuration endpoint.", comment: "")
        case .noDiscoveryDoc:
            return NSLocalizedString("Error loading the discovery document values.", comment: "")
        case .notConfigured:
            return NSLocalizedString("You must first configure the AuthConfig values.", comment: "")
        case .noRefreshToken:
            return NSLocalizedString("No refresh token stored.", comment: "")
        case .noRevocationEndpoint:
            return NSLocalizedString("Error finding the revocation endpoint.", comment: "")
        case .noTokens:
            return NSLocalizedString("No tokens stored in the auth state manager.", comment: "")
        case .noUserInfoEndpoint:
            return NSLocalizedString("Error finding the user info endpoint.", comment: "")
        case .parseFailure:
            return NSLocalizedString("Failed to parse and/or convert object.", comment: "")
        case .invalidHttpResponse:
            return NSLocalizedString("Invalid HTTP response object received after an API call.", comment: "")
        case .missingIdToken:
            return NSLocalizedString("ID token needed to fulfill this operation.", comment: "")
        case .unexpectedAuthCodeResponse(let statusCode):
            return NSLocalizedString("Unexpected response format while retrieving authorization code. Status code: \(statusCode).", comment: "")
        case .userCancelledAuthorizationFlow:
            return NSLocalizedString("The redirect request was cancelled.", comment: "")
        case .unableToGetAuthCode:
            return NSLocalizedString("Unable to get the authorization code.", comment: "")
        case .redirectServerError(error: let error):
            return NSLocalizedString(error, comment: "")
        case let .authorization(error, description):
            return NSLocalizedString("The authorization request failed due to \(error): \(description ?? "").", comment: "")
        case .externalAgentFailed:
            return NSLocalizedString("Failed to create external user agent.", comment: "")
        case .logoutFailed:
            return NSLocalizedString("Failed to complete logout.", comment: "")
        case .loginFailed:
            return NSLocalizedString("Failed to complete login.", comment: "")
        }
    }
}
