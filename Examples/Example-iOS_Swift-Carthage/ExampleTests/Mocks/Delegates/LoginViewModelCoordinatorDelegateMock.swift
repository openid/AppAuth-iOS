//
//  LoginViewModelCoordinatorDelegateMock.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import AppAuth
@testable import Example

class LoginViewModelCoordinatorDelegateMock: LoginViewModelCoordinatorDelegate {
    var loginSucceededCalled: Bool?
    var authenticator: AuthenticatorProtocol?
    
    func loginSucceeded(with authenticator: AuthenticatorProtocol) {
        loginSucceededCalled = true
        self.authenticator = authenticator
    }
}
