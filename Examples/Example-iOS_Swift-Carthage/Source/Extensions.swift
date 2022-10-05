//
//  Extensions.swift
//  Example
//
//  Created by Michael Moore on 10/4/22.
//  Copyright © 2022 Google Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {

    static var loginAnimation: UIViewAnimationOptions = .transitionFlipFromRight
    static var logoutAnimation: UIViewAnimationOptions = .transitionCrossDissolve

    public static func setRootView(_ viewController: UIViewController,
                                   options: UIViewAnimationOptions = .transitionFlipFromRight,
                                   animated: Bool = true,
                                   duration: TimeInterval = 0.5,
                                   completion: (() -> Void)? = nil) {
        guard animated else {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            return
        }

        UIView.transition(with: UIApplication.shared.keyWindow!, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            UIApplication.shared.keyWindow?.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }) { _ in
            completion?()
        }
    }
}

extension UIViewController {

    class var storyboardID: String {
        return "\(self)"
    }

    static func instantiate(from: AppStoryboard) -> Self {
        return from.viewController(viewControllerClass: self)
    }
}

enum AppStoryboard: String {

    case Main = "Main"

    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }

    func viewController<T : UIViewController>(viewControllerClass: T.Type, function: String = #function, line: Int = #line, file: String = #file) -> T {
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID

        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }

        return scene
    }
}
