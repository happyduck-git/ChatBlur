//
//  UITextField+Extensions.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/31/23.
//

import UIKit.UITextField

extension UITextField {
    func setTextFieldBorderColor(_ activate: Bool) {
        self.layer.borderColor = activate ? UIColor.buttonActivated.cgColor : UIColor.buttonDeactivated.cgColor
    }
}
