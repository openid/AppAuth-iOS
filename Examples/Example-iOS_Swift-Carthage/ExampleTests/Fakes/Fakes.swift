//
//  Fakes.swift
//  ExampleTests
//
//  Created by Michael Moore on 1/26/23.
//  Copyright © 2023 Google Inc. All rights reserved.
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
