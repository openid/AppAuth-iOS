//
//  LoginViewModelMock.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All rights reserved.
//

import Foundation
import UIKit
@testable import Example

// MARK: - LoginViewModelMock -

class LoginViewModelMock: BaseViewModel, LoginViewModelProtocol {
    var coordinatorDelegate: LoginViewModelCoordinatorDelegate?
    
    // MARK: - isManualCodeExchange
    
    var isManualCodeExchange: Bool {
        get { underlyingIsManualCodeExchange }
        set(value) { underlyingIsManualCodeExchange = value }
    }
    private var underlyingIsManualCodeExchange: Bool = false
    
    // MARK: - setManualCodeExchange
    
    var setManualCodeExchangeCallsCount = 0
    var setManualCodeExchangeCalled: Bool {
        setManualCodeExchangeCallsCount > 0
    }
    var setManualCodeExchangeReceivedIsSelected: Bool?
    var setManualCodeExchangeReceivedInvocations: [Bool] = []
    var setManualCodeExchangeClosure: ((Bool) -> Void)?
    
    func setManualCodeExchange(_ isSelected: Bool) {
        setManualCodeExchangeCallsCount += 1
        setManualCodeExchangeReceivedIsSelected = isSelected
        setManualCodeExchangeReceivedInvocations.append(isSelected)
        setManualCodeExchangeClosure?(isSelected)
    }
    
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
    
    // MARK: - beginBrowserAuthentication
    
    var beginBrowserAuthenticationThrowableError: Error?
    var beginBrowserAuthenticationCallsCount = 0
    var beginBrowserAuthenticationCalled: Bool {
        beginBrowserAuthenticationCallsCount > 0
    }
    var beginBrowserAuthenticationClosure: (() throws -> Void)?
    
    func beginBrowserAuthentication() throws {
        if let error = beginBrowserAuthenticationThrowableError {
            throw error
        }
        beginBrowserAuthenticationCallsCount += 1
        try beginBrowserAuthenticationClosure?()
    }
    
    // MARK: - authWithAutoCodeExchange
    
    var authWithAutoCodeExchangeThrowableError: Error?
    var authWithAutoCodeExchangeCallsCount = 0
    var authWithAutoCodeExchangeCalled: Bool {
        authWithAutoCodeExchangeCallsCount > 0
    }
    var authWithAutoCodeExchangeClosure: (() throws -> Void)?
    
    func authWithAutoCodeExchange() throws {
        if let error = authWithAutoCodeExchangeThrowableError {
            throw error
        }
        authWithAutoCodeExchangeCallsCount += 1
        try authWithAutoCodeExchangeClosure?()
    }
    
    // MARK: - authWithManualCodeExchange
    
    var authWithManualCodeExchangeThrowableError: Error?
    var authWithManualCodeExchangeCallsCount = 0
    var authWithManualCodeExchangeCalled: Bool {
        authWithManualCodeExchangeCallsCount > 0
    }
    var authWithManualCodeExchangeClosure: (() throws -> Void)?
    
    func authWithManualCodeExchange() throws {
        if let error = authWithManualCodeExchangeThrowableError {
            throw error
        }
        authWithManualCodeExchangeCallsCount += 1
        try authWithManualCodeExchangeClosure?()
    }
}
