//
//  Fakes.swift
//  ExampleTests
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import XCTest
@testable import Example

class FakeUserDefaults: UserDefaultsProtocol {
    
    var dataDict: [String: Any] = [:]
    var boolValue: Bool = false
    
    func data(forKey defaultName: String) -> Data? {
        return dataDict[defaultName] as? Data
    }
    
    func bool(forKey defaultName: String) -> Bool {
        return boolValue
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        dataDict[defaultName] = value
    }
    
    func set(_ value: Bool, forKey defaultName: String) {
        boolValue = value
    }
}
