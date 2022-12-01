//
//  LogoutOptionsControllerCell.swift
//  Example
//
//  Created by Michael Moore on 11/22/22.
//  Copyright © 2022 Google Inc. All rights reserved.
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
