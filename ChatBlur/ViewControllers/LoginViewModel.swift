//
//  LoginViewModel.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/29/23.
//

import Foundation
import RxSwift
import RxCocoa
import AuthenticationServices

final class LoginViewModel: NSObject, ViewModelType {
        
    struct Input {
        let emailTextType: Observable<String>
        let passwordTextType: Observable<String>
    }
    
    struct Output {
        let shouldActivate: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let isValid = Observable.combineLatest(input.emailTextType, input.passwordTextType)
            .compactMap { (email, pwd) in
                return !email.isEmpty && !pwd.isEmpty
            }
            .asDriver(onErrorJustReturn: false)
        
        return Output(shouldActivate: isValid)
    }
}
