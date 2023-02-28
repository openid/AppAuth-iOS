//
//  SpyNavigationController.swift
//  ExampleTests
//
//  Created by Michael Moore on 1/26/23.
//  Copyright © 2023 Google Inc. All rights reserved.
//

import Foundation
import UIKit
@testable import Example

class SpyNavigationController: UINavigationController {
    
    var pushedViewController: UIViewController?
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
        super.pushViewController(viewController, animated: true)
    }
}
