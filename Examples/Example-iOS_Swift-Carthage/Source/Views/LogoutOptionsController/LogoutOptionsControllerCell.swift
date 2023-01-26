//
//  LogoutOptionsControllerCell.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All Rights Reserved.
//

import UIKit

class LogoutOptionsControllerCell: UITableViewCell {
    class var identifier: String {
        return String.className(self)
    }

    class func height() -> CGFloat {
        return 44.0
    }

    func setData(_ data: Any?) {
        if let logoutType = data as? LogoutType {
            self.textLabel?.text = logoutType.rawValue
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
