//
//  AppAuthMocks.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import AppAuth
import XCTest
@testable import Example

class AppAuthMocks {
    
    static let mockDiscoveryDoc = AppAuthMocks.loadDiscoveryDocument()
    static let mockAccessToken = "NjOZSd15rx1Z1_GboqGk4eXjOwi-EKJy979zeddssc5I-b2HNVWzzpvZn3xtnl9s"
    static let mockRefreshToken = "wH1dvR_WH_hZEPjShzeZv0X4gehbrbpmrSmeWLbyQpINA84wO0f4G48crANSZ5QD"
    static let mockIdToken =
    "eyJhbGciOiJSUzI1NiIsImtpZCI6IjViMDUzYWZiNjM3NzZhMTI3ZWM1YzE4YmI1NDNlM2JjY2VlZjQxNjAiLCJ0eXAiOiJKV1" +
    "QifQ.eyJhY3IiOiJ1cm46YWthbWFpLWljOm5pc3Q6ODAwLTYzLTM6YWFsOjEiLCJhbXIiOlsicHdkIl0sImF0X2hhc2giOiIwQ" +
    "zBLaHBaNmxyQ09yVWlxa3FrcE53IiwiYXVkIjpbIjExYTUwNTEyLWZlM2EtNGRjMi04N2E5LWRkNzhjNmRkODNmMiJdLCJhdXR" +
    "oX3RpbWUiOjE2Nzc2MDIzMjEsImF6cCI6IjExYTUwNTEyLWZlM2EtNGRjMi04N2E5LWRkNzhjNmRkODNmMiIsImV4cCI6MTY3N" +
    "zYwNTkyNSwiZ2xvYmFsX3N1YiI6ImNhcHR1cmUtdjE6Ly9jYXB0dXJlLWFsYi1ib3JkZXIubXVsdGkuZGV2Lm9yLmphbnJhaW4" +
    "uY29tL3gzZ21ubmpleXp5cnJ0Mm5tNWRyZjVua244L3VzZXIvMzA2ZjEyNjktZTA2MS00MjAyLTljNDgtMTc0ZTM5ODMyZDhiI" +
    "iwiaWF0IjoxNjc3NjAyMzI1LCJpc3MiOiJodHRwczovL2FwaS5tdWx0aS5kZXYub3IuamFucmFpbi5jb20vMDAwMDAwMDAtMDA" +
    "wMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwL2xvZ2luIiwianRpIjoiZ1Nya05kdExyOE52Q1B5WjRsVi1OWUxOIiwicHJlZmVyc" +
    "mVkX3VzZXJuYW1lIjoiTWljaGFlbCBNb29yZSIsInNpZCI6IjdlNGFjYmZkLTdjYjMtNDFhOC1hY2UzLTAwNGQ5YTQyNTA3NiI" +
    "sInN1YiI6IjMwNmYxMjY5LWUwNjEtNDIwMi05YzQ4LTE3NGUzOTgzMmQ4YiIsInVwZGF0ZWRfYXQiOjE2Nzc2MDIzMTl9.F-bX" +
    "F6e5V0mwoDIXwAP0OpWbBXe2e0YPrltJl7paulBvVa5pDkrrj4lI1CtAb1_RN0T_sO74jeyxRbiJwkFFnX7Sd-S4GsnhTRIFNK" +
    "YajmhzNQ3m0uxuhY4-u7wPcuGT0fDBDwlm2TiP0vqTsR3sBtA73683-thv0BSGfPZ3OdGeTCSb1NtjjgD5cME0HTmQi0Ppt325" +
    "GCz_fIPWsAMxP_vaXfgl2ETpKvNA4nuwYBqIEx9MdVg2gPRvq0E4tDMgqLA_i7csDAR-UoHdnsPs8CqptMHoGHLJshmgdJ762q" +
    "a6AdOXhlV4DUTxeO8eY3Ce87uxxHw3z0GLflZwHD55rQ"
    
    static var authStateManager = { return AppAuthMocks.setupMockAuthStateManager(issuer: AuthConfig.discoveryUrl, clientId: AuthConfig.clientId) }
    static var authStateManagerWithExpiration = { return AppAuthMocks.setupMockAuthStateManager(issuer: AuthConfig.discoveryUrl, clientId: AuthConfig.clientId, expiresIn: 5) }
    
    static func makeMockServiceConfig(issuer: URL) -> OIDServiceConfiguration {
        AppAuthMocks.getConfigurationMock()!
    }
    
    static func setupMockAuthState(issuer: URL = AuthConfig.discoveryUrl,
                                   clientId: String = AuthConfig.clientId,
                                   expiresIn: TimeInterval = 300,
                                   refreshToken: String = mockRefreshToken,
                                   skipTokenResponse: Bool = false) -> OIDAuthState {
        
        // Creates a mock Auth State Manager object
        let mockServiceConfig = makeMockServiceConfig(issuer: issuer)
        
        let mockTokenRequest = OIDTokenRequest(
            configuration: mockServiceConfig,
            grantType: OIDGrantTypeRefreshToken,
            authorizationCode: nil,
            redirectURL: issuer,
            clientID: "nil",
            clientSecret: nil,
            scope: nil,
            refreshToken: nil,
            codeVerifier: nil,
            additionalParameters: nil
        )
        
        let mockAuthRequest = OIDAuthorizationRequest(
            configuration: mockServiceConfig,
            clientId: clientId,
            clientSecret: nil,
            scopes: ["openid", "email"],
            redirectURL: issuer,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil
        )
        
        let mockAuthResponse = OIDAuthorizationResponse(
            request: mockAuthRequest,
            parameters: ["code": "mockAuthCode" as NSCopying & NSObjectProtocol]
        )
        
        if skipTokenResponse {
            return OIDAuthState(authorizationResponse: mockAuthResponse)
        } else {
            let mockTokenResponse = OIDTokenResponse(
                request: mockTokenRequest,
                parameters: [
                    "access_token": mockAccessToken as NSCopying & NSObjectProtocol,
                    "expires_in": expiresIn as NSCopying & NSObjectProtocol,
                    "token_type": "Bearer" as NSCopying & NSObjectProtocol,
                    "id_token": mockIdToken as NSCopying & NSObjectProtocol,
                    "refresh_token": refreshToken as NSCopying & NSObjectProtocol,
                    "scope": (AuthConfig.scopes?.joined(separator: " ") ?? "") as NSCopying & NSObjectProtocol
                ]
            )
            
            return OIDAuthState(authorizationResponse: mockAuthResponse, tokenResponse: mockTokenResponse)
        }
    }
    
    static func setupMockAuthStateManager(issuer: URL, clientId: String, expiresIn: TimeInterval = 300) -> AuthStateManager {
        let tempAuthState = setupMockAuthState(issuer: issuer, clientId: clientId, expiresIn: expiresIn)
        let authStateManager = AuthStateManager()
        authStateManager.setAuthState(tempAuthState)
        return authStateManager
    }
    
    static func loadDiscoveryDocument() -> OIDServiceDiscovery? {
        
        let jsonData = givenData(sourceName: "openid-configuration")!
        let discoveryDoc = try? OIDServiceDiscovery(jsonData: jsonData)
        return discoveryDoc
    }
    
    static func getConfigurationMock() -> OIDServiceConfiguration? {
        guard let discoveryDoc = loadDiscoveryDocument() else { return nil }
        return OIDServiceConfiguration(discoveryDocument: discoveryDoc)
    }
    
    static func getAuthRequestMock() -> OIDAuthorizationRequest? {
        guard let configuration = getConfigurationMock() else { return nil }
        return OIDAuthorizationRequest(configuration: configuration, clientId: AuthConfig.clientId, scopes: AuthConfig.scopes, redirectURL: AuthConfig.redirectUrl, responseType: OIDResponseTypeCode, additionalParameters: AuthConfig.additionalParameters)
    }
    
    static func getTokenRequestMock() -> OIDTokenRequest? {
        guard let configuration = getConfigurationMock() else { return nil }
        return OIDTokenRequest(configuration: configuration, grantType: OIDGrantTypeAuthorizationCode, authorizationCode: nil, redirectURL: AuthConfig.redirectUrl, clientID: AuthConfig.clientId, clientSecret: nil, scopes: AuthConfig.scopes, refreshToken: nil, codeVerifier: nil, additionalParameters: nil)
    }
    
    static func getTokenResponseMock() -> OIDTokenResponse? {
        guard let request = getTokenRequestMock() else { return nil }
        return OIDTokenResponse(request: request, parameters: [:])
    }
    
    static func getAuthResponseMock() -> OIDAuthorizationResponse? {
        guard let request = getAuthRequestMock() else { return nil }
        return OIDAuthorizationResponse(request: request, parameters: [:])
    }
    
    static func givenData(sourceName: String) -> Data? {
        guard let pathString = Bundle(for: self).path(forResource: sourceName, ofType: "json") else {
            fatalError("\(sourceName).json not found")
        }
        
        return try? Data(contentsOf: URL(fileURLWithPath: pathString), options: .mappedIfSafe)
    }
}
