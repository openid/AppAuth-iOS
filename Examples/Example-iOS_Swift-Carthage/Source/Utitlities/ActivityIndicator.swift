//
//  ActivityIndicator.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import Foundation
import UIKit

class ActivityIndicator {
    
    static let sharedIndicator = ActivityIndicator()
    private var spinnerView = UIView()
    
    func displayActivityIndicator(onView : UIView) {
        spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async { [weak self] in
            guard let _self = self else { return }
            _self.spinnerView.addSubview(ai)
            onView.addSubview(_self.spinnerView)
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {[weak self] in
            guard let _self = self else { return }
            _self.spinnerView.removeFromSuperview()
        }
    }
}
