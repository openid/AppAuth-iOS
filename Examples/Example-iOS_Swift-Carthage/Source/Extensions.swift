//
//  Extensions.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

extension UIViewController {

    class var storyboardID: String {
        return "\(self)"
    }

    static func instantiate(from: AppStoryboard) -> Self {
        return from.viewController(viewControllerClass: self)
    }
    
    func setActivityIndicator(_ visible: Bool) {
        if visible {
            ActivityIndicator.sharedIndicator.displayActivityIndicator(onView: self.view)
        } else {
            ActivityIndicator.sharedIndicator.hideActivityIndicator()
        }
    }
    
    /**
     Provides options for custom print output.
     */
    func customPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        var output = items.map { "\($0)" }.joined(separator: separator)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        
        output = date + " " + output
        
        Swift.print(output)
    }
    
    func displayAlert(title: String = TextConstants.errorTitle, error: AuthError? = nil, buttonTitle: String? = nil, alertAction: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: error?.errorDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle ?? TextConstants.ok, style: .default) { (action) in
            alertAction?()
        }
        
        alertController.addAction(action)
        
        self.present(alertController, animated: true) {
            self.setActivityIndicator(false)
        }
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

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
}
