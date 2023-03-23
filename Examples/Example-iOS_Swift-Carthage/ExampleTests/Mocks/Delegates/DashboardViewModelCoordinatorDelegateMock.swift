//
//  DashboardViewModelCoordinatorDelegateMock.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import AppAuth
@testable import Example

class DashboardViewModelCoordinatorDelegateMock: DashboardViewModelCoordinatorDelegate {
    var logoutSucceededCalled: Bool?
    
    func logoutSucceeded() {
        logoutSucceededCalled = true
    }
}
