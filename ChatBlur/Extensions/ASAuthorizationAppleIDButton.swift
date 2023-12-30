//
//  ASAuthorizationAppleIDButton.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/29/23.
//

import RxSwift
import RxCocoa
import AuthenticationServices
import UIKit

extension Reactive where Base: ASAuthorizationAppleIDButton {
    public var tap: ControlEvent<Void> {
        controlEvent(.touchUpInside)
    }
}
