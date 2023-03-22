//
//  AuthStateManagerMock.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All rights reserved.
//

import Foundation
import AppAuth
@testable import Example

// MARK: - AuthStateManagerMock -

class AuthStateManagerMock: NSObject, AuthStateManagerProtocol {
    var authState: OIDAuthState?
    
    // MARK: - browserState
    
    var browserState: State {
        get { underlyingBrowserState }
        set(value) { underlyingBrowserState = value }
    }
    private var underlyingBrowserState: State!
    
    // MARK: - authorizationState
    
    var authorizationState: State {
        get { underlyingAuthorizationState }
        set(value) { underlyingAuthorizationState = value }
    }
    private var underlyingAuthorizationState: State!
    var accessToken: String?
    
    // MARK: - accessTokenState
    
    var accessTokenState: State {
        get { underlyingAccessTokenState }
        set(value) { underlyingAccessTokenState = value }
    }
    private var underlyingAccessTokenState: State!
    var refreshToken: String?
    
    // MARK: - refreshTokenState
    
    var refreshTokenState: State {
        get { underlyingRefreshTokenState }
        set(value) { underlyingRefreshTokenState = value }
    }
    private var underlyingRefreshTokenState: State!
    var lastTokenResponse: OIDTokenResponse?
    var tokenRefreshRequest: OIDTokenRequest?
    var lastAuthorizationResponse: OIDAuthorizationResponse?
    var tokenExchangeRequest: OIDTokenRequest?
    
    // MARK: - setTokenState
    
    var setTokenStateStateCallsCount = 0
    var setTokenStateStateCalled: Bool {
        setTokenStateStateCallsCount > 0
    }
    var setTokenStateStateReceivedArguments: (tokenType: TokenType, state: State)?
    var setTokenStateStateReceivedInvocations: [(tokenType: TokenType, state: State)] = []
    var setTokenStateStateClosure: ((TokenType, State) -> Void)?
    
    func setTokenState(_ tokenType: TokenType, state: State) {
        setTokenStateStateCallsCount += 1
        setTokenStateStateReceivedArguments = (tokenType: tokenType, state: state)
        setTokenStateStateReceivedInvocations.append((tokenType: tokenType, state: state))
        setTokenStateStateClosure?(tokenType, state)
    }
    
    // MARK: - loadAuthState
    
    var loadAuthStateCallsCount = 0
    var loadAuthStateCalled: Bool {
        loadAuthStateCallsCount > 0
    }
    var loadAuthStateClosure: (() -> Void)?
    
    func loadAuthState() {
        loadAuthStateCallsCount += 1
        loadAuthStateClosure?()
    }
    
    // MARK: - setAuthState
    
    var setAuthStateCallsCount = 0
    var setAuthStateCalled: Bool {
        setAuthStateCallsCount > 0
    }
    var setAuthStateReceivedAuthState: OIDAuthState?
    var setAuthStateReceivedInvocations: [OIDAuthState?] = []
    var setAuthStateClosure: ((OIDAuthState?) -> Void)?
    
    func setAuthState(_ authState: OIDAuthState?) {
        setAuthStateCallsCount += 1
        setAuthStateReceivedAuthState = authState
        setAuthStateReceivedInvocations.append(authState)
        setAuthStateClosure?(authState)
    }
    
    // MARK: - updateWithTokenResponse
    
    var updateWithTokenResponseErrorCallsCount = 0
    var updateWithTokenResponseErrorCalled: Bool {
        updateWithTokenResponseErrorCallsCount > 0
    }
    var updateWithTokenResponseErrorReceivedArguments: (response: OIDTokenResponse?, error: Error?)?
    var updateWithTokenResponseErrorReceivedInvocations: [(response: OIDTokenResponse?, error: Error?)] = []
    var updateWithTokenResponseErrorClosure: ((OIDTokenResponse?, Error?) -> Void)?
    
    func updateWithTokenResponse(_ response: OIDTokenResponse?, error: Error?) {
        updateWithTokenResponseErrorCallsCount += 1
        updateWithTokenResponseErrorReceivedArguments = (response: response, error: error)
        updateWithTokenResponseErrorReceivedInvocations.append((response: response, error: error))
        updateWithTokenResponseErrorClosure?(response, error)
    }
    
    // MARK: - loadBrowserState
    
    var loadBrowserStateCallsCount = 0
    var loadBrowserStateCalled: Bool {
        loadBrowserStateCallsCount > 0
    }
    var loadBrowserStateClosure: (() -> Void)?
    
    func loadBrowserState() {
        loadBrowserStateCallsCount += 1
        loadBrowserStateClosure?()
    }
    
    // MARK: - setBrowserState
    
    var setBrowserStateCallsCount = 0
    var setBrowserStateCalled: Bool {
        setBrowserStateCallsCount > 0
    }
    var setBrowserStateReceivedState: State?
    var setBrowserStateReceivedInvocations: [State] = []
    var setBrowserStateClosure: ((State) -> Void)?
    
    func setBrowserState(_ state: State) {
        setBrowserStateCallsCount += 1
        setBrowserStateReceivedState = state
        setBrowserStateReceivedInvocations.append(state)
        setBrowserStateClosure?(state)
        browserState = state
    }
    
    // MARK: - getStateData
    
    var getStateDataCallsCount = 0
    var getStateDataCalled: Bool {
        getStateDataCallsCount > 0
    }
    var getStateDataReturnValue: String!
    var getStateDataClosure: (() -> String)?
    
    func getStateData() -> String {
        getStateDataCallsCount += 1
        return getStateDataClosure.map({ $0() }) ?? getStateDataReturnValue
    }
}
