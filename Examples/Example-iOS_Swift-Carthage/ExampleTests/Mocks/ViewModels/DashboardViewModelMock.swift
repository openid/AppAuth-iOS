//
//  DashboardViewModelMock.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All rights reserved.
//


import Foundation
import UIKit
@testable import Example

// MARK: - DashboardViewModelMock -

class DashboardViewModelMock: BaseViewModel, DashboardViewModelProtocol {
    var coordinatorDelegate: DashboardViewModelCoordinatorDelegate?
    
    // MARK: - isBrowserSessionActive
    
    var isBrowserSessionActive: Bool {
        get { underlyingIsBrowserSessionActive }
        set(value) { underlyingIsBrowserSessionActive = value }
    }
    private var underlyingIsBrowserSessionActive: Bool = false
    
    // MARK: - isTokenRequestStackViewHidden
    
    var isTokenRequestStackViewHidden: Bool {
        get { underlyingIsTokenRequestStackViewHidden }
        set(value) { underlyingIsTokenRequestStackViewHidden = value }
    }
    private var underlyingIsTokenRequestStackViewHidden: Bool = false
    
    // MARK: - isTokenDataStackViewHidden
    
    var isTokenDataStackViewHidden: Bool {
        get { underlyingIsTokenDataStackViewHidden }
        set(value) { underlyingIsTokenDataStackViewHidden = value }
    }
    private var underlyingIsTokenDataStackViewHidden: Bool = false
    
    // MARK: - isCodeExchangeButtonHidden
    
    var isCodeExchangeButtonHidden: Bool {
        get { underlyingIsCodeExchangeButtonHidden }
        set(value) { underlyingIsCodeExchangeButtonHidden = value }
    }
    private var underlyingIsCodeExchangeButtonHidden: Bool = true
    
    // MARK: - isRefreshTokenButtonHidden
    
    var isRefreshTokenButtonHidden: Bool {
        get { underlyingIsRefreshTokenButtonHidden }
        set(value) { underlyingIsRefreshTokenButtonHidden = value }
    }
    private var underlyingIsRefreshTokenButtonHidden: Bool = false
    
    // MARK: - isUserinfoButtonHidden
    
    var isUserinfoButtonHidden: Bool {
        get { underlyingIsUserinfoButtonHidden }
        set(value) { underlyingIsUserinfoButtonHidden = value }
    }
    private var underlyingIsUserinfoButtonHidden: Bool = false
    
    // MARK: - isProfileButtonHidden
    
    var isProfileButtonHidden: Bool {
        get { underlyingIsProfileButtonHidden }
        set(value) { underlyingIsProfileButtonHidden = value }
    }
    private var underlyingIsProfileButtonHidden: Bool = false
    
    // MARK: - accessTokenTextViewText
    
    var accessTokenTextViewText: String {
        get { underlyingAccessTokenTextViewText }
        set(value) { underlyingAccessTokenTextViewText = value }
    }
    private var underlyingAccessTokenTextViewText: String = TextConstants.accessToken
    
    // MARK: - accessTokenTitleLabelText
    
    var accessTokenTitleLabelText: String {
        get { underlyingAccessTokenTitleLabelText }
        set(value) { underlyingAccessTokenTitleLabelText = value }
    }
    private var underlyingAccessTokenTitleLabelText: String = AppAuthMocks().mockAccessToken
    
    // MARK: - refreshTokenTextViewText
    
    var refreshTokenTextViewText: String {
        get { underlyingRefreshTokenTextViewText }
        set(value) { underlyingRefreshTokenTextViewText = value }
    }
    private var underlyingRefreshTokenTextViewText: String = AppAuthMocks().mockAccessToken
    
    // MARK: - refreshTokenTitleLabelText
    
    var refreshTokenTitleLabelText: String {
        get { underlyingRefreshTokenTitleLabelText }
        set(value) { underlyingRefreshTokenTitleLabelText = value }
    }
    private var underlyingRefreshTokenTitleLabelText: String = TextConstants.refreshToken
    
    // MARK: - discoverConfiguration
    
    var discoverConfigurationThrowableError: Error?
    var discoverConfigurationCallsCount = 0
    var discoverConfigurationCalled: Bool {
        discoverConfigurationCallsCount > 0
    }
    var discoverConfigurationReturnValue: String!
    var discoverConfigurationClosure: (() throws -> String)?
    
    func discoverConfiguration() throws -> String {
        if let error = discoverConfigurationThrowableError {
            throw error
        }
        discoverConfigurationCallsCount += 1
        return try discoverConfigurationClosure.map({ try $0() }) ?? discoverConfigurationReturnValue
    }
    
    // MARK: - checkBrowserSession
    
    var checkBrowserSessionThrowableError: Error?
    var checkBrowserSessionCallsCount = 0
    var checkBrowserSessionCalled: Bool {
        checkBrowserSessionCallsCount > 0
    }
    var checkBrowserSessionClosure: (() throws -> Void)?
    
    func checkBrowserSession() throws {
        if let error = checkBrowserSessionThrowableError {
            throw error
        }
        checkBrowserSessionCallsCount += 1
        try checkBrowserSessionClosure?()
    }
    
    // MARK: - loadProfileManagement
    
    var loadProfileManagementThrowableError: Error?
    var loadProfileManagementCallsCount = 0
    var loadProfileManagementCalled: Bool {
        loadProfileManagementCallsCount > 0
    }
    var loadProfileManagementClosure: (() throws -> Void)?
    
    func loadProfileManagement() throws {
        if let error = loadProfileManagementThrowableError {
            throw error
        }
        loadProfileManagementCallsCount += 1
        try loadProfileManagementClosure?()
    }
    
    // MARK: - refreshTokens
    
    var refreshTokensThrowableError: Error?
    var refreshTokensCallsCount = 0
    var refreshTokensCalled: Bool {
        refreshTokensCallsCount > 0
    }
    var refreshTokensClosure: (() throws -> Void)?
    
    func refreshTokens() throws {
        if let error = refreshTokensThrowableError {
            throw error
        }
        refreshTokensCallsCount += 1
        try refreshTokensClosure?()
    }
    
    // MARK: - getUserInfo
    
    var getUserInfoThrowableError: Error?
    var getUserInfoCallsCount = 0
    var getUserInfoCalled: Bool {
        getUserInfoCallsCount > 0
    }
    var getUserInfoReturnValue: String!
    var getUserInfoClosure: (() throws -> String)?
    
    func getUserInfo() throws -> String {
        if let error = getUserInfoThrowableError {
            throw error
        }
        getUserInfoCallsCount += 1
        return try getUserInfoClosure.map({ try $0() }) ?? getUserInfoReturnValue
    }
    
    // MARK: - exchangeAuthorizationCode
    
    var exchangeAuthorizationCodeThrowableError: Error?
    var exchangeAuthorizationCodeCallsCount = 0
    var exchangeAuthorizationCodeCalled: Bool {
        exchangeAuthorizationCodeCallsCount > 0
    }
    var exchangeAuthorizationCodeClosure: (() throws -> Void)?
    
    func exchangeAuthorizationCode() throws {
        if let error = exchangeAuthorizationCodeThrowableError {
            throw error
        }
        exchangeAuthorizationCodeCallsCount += 1
        try exchangeAuthorizationCodeClosure?()
    }
    
    // MARK: - getLogoutOptionsAlert
    
    var getLogoutOptionsAlertCallsCount = 0
    var getLogoutOptionsAlertCalled: Bool {
        getLogoutOptionsAlertCallsCount > 0
    }
    var getLogoutOptionsAlertReceivedCompletion: LogoutAlertCompletionHandler?
    var getLogoutOptionsAlertReceivedInvocations: [LogoutAlertCompletionHandler] = []
    var getLogoutOptionsAlertReturnValue: UIAlertController!
    var getLogoutOptionsAlertClosure: ((@escaping LogoutAlertCompletionHandler) -> UIAlertController)?
    
    func getLogoutOptionsAlert(_ completion: @escaping LogoutAlertCompletionHandler) -> UIAlertController {
        getLogoutOptionsAlertCallsCount += 1
        getLogoutOptionsAlertReceivedCompletion = completion
        getLogoutOptionsAlertReceivedInvocations.append(completion)
        return getLogoutOptionsAlertClosure.map({ $0(completion) }) ?? getLogoutOptionsAlertReturnValue
    }
    
    // MARK: - revokeTokens
    
    var revokeTokensThrowableError: Error?
    var revokeTokensCallsCount = 0
    var revokeTokensCalled: Bool {
        revokeTokensCallsCount > 0
    }
    var revokeTokensClosure: (() throws -> Void)?
    
    func revokeTokens() throws {
        if let error = revokeTokensThrowableError {
            throw error
        }
        revokeTokensCallsCount += 1
        try revokeTokensClosure?()
    }
    
    // MARK: - browserLogout
    
    var browserLogoutThrowableError: Error?
    var browserLogoutCallsCount = 0
    var browserLogoutCalled: Bool {
        browserLogoutCallsCount > 0
    }
    var browserLogoutClosure: (() throws -> Void)?
    
    func browserLogout() throws {
        if let error = browserLogoutThrowableError {
            throw error
        }
        browserLogoutCallsCount += 1
        try browserLogoutClosure?()
    }
    
    // MARK: - appLogout
    
    var appLogoutThrowableError: Error?
    var appLogoutCallsCount = 0
    var appLogoutCalled: Bool {
        appLogoutCallsCount > 0
    }
    var appLogoutClosure: (() throws -> Void)?
    
    func appLogout() throws {
        if let error = appLogoutThrowableError {
            throw error
        }
        appLogoutCallsCount += 1
        try appLogoutClosure?()
    }
    
    // MARK: - handleLogoutSelections
    
    var handleLogoutSelectionsCompletionCallsCount = 0
    var handleLogoutSelectionsCompletionCalled: Bool {
        handleLogoutSelectionsCompletionCallsCount > 0
    }
    var handleLogoutSelectionsCompletionReceivedArguments: (selections: Set<LogoutType>, completion: LogoutAlertCompletionHandler?)?
    var handleLogoutSelectionsCompletionReceivedInvocations: [(selections: Set<LogoutType>, completion: LogoutAlertCompletionHandler?)] = []
    var handleLogoutSelectionsCompletionClosure: ((Set<LogoutType>, LogoutAlertCompletionHandler?) -> Void)?
    
    func handleLogoutSelections(_ selections: Set<LogoutType>, completion: LogoutAlertCompletionHandler?) {
        handleLogoutSelectionsCompletionCallsCount += 1
        handleLogoutSelectionsCompletionReceivedArguments = (selections: selections, completion: completion)
        handleLogoutSelectionsCompletionReceivedInvocations.append((selections: selections, completion: completion))
        handleLogoutSelectionsCompletionClosure?(selections, completion)
    }
}
