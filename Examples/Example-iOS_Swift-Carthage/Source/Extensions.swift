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
    
    func displayAlert(title: String = TextConstants.errorTitle, error: AuthError? = nil, buttonTitle: String? = nil, alertAction: Optional<() -> Void> = nil) {
        
        let alertController = UIAlertController(title: title, message: error?.userMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle ?? TextConstants.ok, style: .default) { (action) in
            alertAction?()
        }
        
        alertController.addAction(action)
        
        self.present(alertController, animated: true)
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

extension UIColor {
    
    public convenience init?(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return nil
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0))
    }
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


extension UIColor {
    static func defaultButtonTextColor() -> UIColor {
        return UIColor(red: 0.0, green: 123/255, blue: 1.0, alpha: 1)
    }

    static func defaultDialogTextColor() -> UIColor {
        return UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    }

    static func defaultDialogBorderColor() -> UIColor {
        return UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0)
    }
}

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
}
