//
//  SignupViewModel.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/31/23.
//

import Foundation
import RxSwift
import RxCocoa

enum SignupError: Error {
    case testErr
}

final class SignupViewModel: ViewModelType {
    
    private let supabaseManager = SupabaseManager.shared
    
    struct Input {
        let username: Observable<String>
        let email: Observable<String>
        let password: Observable<String>
        let passwordCheck: Observable<String>
        let signupBtnTrigger: Observable<Void>
    }
    
    struct Output {
        let isUsernameValid: Driver<Bool>
        let isEmailValid: Driver<Bool>
        let isPasswordValid: Driver<Bool>
        let isSamePassword: Driver<Bool>
        let activateSignup: Driver<Bool>
        let isLoading: PublishRelay<Bool>
        let signupTriggered: Observable<Void>
        let error: Observable<Error>
    }
    
    func transform(input: Input) -> Output {

        let errorRelay:PublishRelay<Error> = PublishRelay<Error>()
        
        let isUsernameValid = input.username.compactMap { [weak self] in
            guard let `self` = self else { return false }
            return self.validateUsername($0)
        }.asDriver(onErrorJustReturn: false)
        
        let isUserEmpty = input.username.compactMap {
            return $0.isEmpty
        }.asDriver(onErrorJustReturn: false)
        
        let isEmailValid = input.email.compactMap { [weak self] in
            guard let `self` = self else { return false }
            return self.validateEmail($0)
        }.asDriver(onErrorJustReturn: false)
        
        let isEmailEmpty = input.email.compactMap {
            return $0.isEmpty
        }.asDriver(onErrorJustReturn: false)
        
        let isPasswordValid = input.password.compactMap { [weak self] in
            guard let `self` = self else { return false }
            return self.validatePassword($0)
        }.asDriver(onErrorJustReturn: false)
        
        let isPasswordEmpty = input.password.compactMap {
            return $0.isEmpty
        }.asDriver(onErrorJustReturn: false)
        
        let isSame = Observable.combineLatest(
            input.password,
            input.passwordCheck
        ) {
            return $0 == $1
        }.asDriver(onErrorJustReturn: false)
        
        let activate = Driver.combineLatest(isUsernameValid,
                                            isEmailValid,
                                            isPasswordValid,
                                            isSame,
                                            isUserEmpty,
                                            isEmailEmpty,
                                            isPasswordEmpty) {
            return $0 && $1 && $2 && $3 && !$4 && !$5 && !$6
        }
        
        let signupInfo = Observable.combineLatest(input.email, input.password).compactMap { $0 }
        
        let isLoading = PublishRelay<Bool>()
        
        let signup = input.signupBtnTrigger.withLatestFrom(signupInfo)
            .map { [weak self] email, pwd in
                guard let `self` = self else { return }
                isLoading.accept(true)
                Task {
                    do {
                        print("Save triggered")
                        try await Task.sleep(nanoseconds: 2_000_000_000)
    //                    await self.signupWithEmailAndPassword(email: email, password: pwd)
                        isLoading.accept(false)
      
                    }
                    catch {
                        print("Error ")
                        errorRelay.accept(error)
                    }
                }
            }.asObservable()
        
        return Output(isUsernameValid: isUsernameValid,
                      isEmailValid: isEmailValid,
                      isPasswordValid: isPasswordValid,
                      isSamePassword: isSame,
                      activateSignup: activate,
                      isLoading: isLoading,
                      signupTriggered: signup,
                      error: errorRelay.asObservable())
    }
}

// Input to Ouput transition
extension SignupViewModel {
    func validateUsername(_ username: String) -> Bool {
        if username.isEmpty { return true }
        
        let usernameRegex = SignupConstants.usernameRegex
        let maximumUsernameLength = 12
        
        let isLengthValid = username.count < maximumUsernameLength
        
        let isContentValid = username.range(
            of: usernameRegex,
            options: .regularExpression
        ) != nil
        
        return isLengthValid && isContentValid
    }
    
    func validateEmail(_ email: String) -> Bool {
        if email.isEmpty { return true }
        
        let emailRegex = SignupConstants.emailRegex
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    func validatePassword(_ password: String) -> Bool {
        if password.isEmpty { return true }
        
        let passwordRex = SignupConstants.passwordRegex
        return password.range(of: passwordRex, options: .regularExpression) != nil
    }
}

// Sign Up
extension SignupViewModel {
    func signupWithEmailAndPassword(email: String, password: String) async throws {
        try await supabaseManager.loginWithEmailAndPassword(email: email,
                                                            password: password)
    }
}
