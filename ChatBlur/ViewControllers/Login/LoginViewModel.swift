//
//  LoginViewModel.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/29/23.
//

import UIKit.UIViewController
import RxSwift
import RxCocoa
import AuthenticationServices
import Supabase

final class LoginViewModel: NSObject, ViewModelType {
    
    private let supabaseManager: SupabaseManager = SupabaseManager.shared
    private var appleLoginManager: AppleLoginManager?
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let emailLoginBtnTrigger: Observable<Void>
        let appleLoginBtnTrigger: Observable<UIViewController>
    }
    
    struct Output {
        let shouldActivate: Driver<Bool>
        let isLoading: PublishRelay<Bool>
        let signInTriggered: Observable<Void>
        let appleSigninTriggered: Observable<Void>
        let session: PublishRelay<Session>
        let error: PublishRelay<Error>
    }
    
    func transform(input: Input) -> Output {
        let errorRelay:PublishRelay<Error> = PublishRelay<Error>()
        
        let isValid = Observable.combineLatest(input.email, input.password)
            .compactMap { (email, pwd) in
                return !email.isEmpty && !pwd.isEmpty
            }
            .asDriver(onErrorJustReturn: false)
        
        let signinInfo = Observable.combineLatest(input.email, input.password).compactMap { $0 }
        let isLoading = PublishRelay<Bool>()
        let session = PublishRelay<Session>()
        
        let signInTriggered = input.emailLoginBtnTrigger
            .withLatestFrom(signinInfo)
            .map { [weak self] email, password in
                guard let `self` = self else { return }
                isLoading.accept(true)
                Task {
                    do {
                        session.accept(try await self.loginWithEmailAndPassword(email: email, password: password))
                    }
                    catch {
                        errorRelay.accept(error)
                    }
                    isLoading.accept(false)
                }
            }
        
        let appleLoginBtnTrigger = input.appleLoginBtnTrigger
            .map { [weak self] in
                guard let `self` = self else { return }

                self.appleLoginManager = AppleLoginManager(loginViewController: $0)
                guard let manager = self.appleLoginManager else { return }

                manager.loginToken.subscribe(onNext: { token in
                    print("TOekn: \(token)")
                    Task {
                        do {
                            session.accept(try await self.appleLogin(token: token))
                        }
                        catch {
                            errorRelay.accept(error)
                        }
                    }
                })
                .disposed(by: disposeBag)
                
                manager.loginError.subscribe(onNext: { error in
                    errorRelay.accept(error)
                })
                .disposed(by: disposeBag)
                
                manager.authorize()
                
            }
        
        return Output(shouldActivate: isValid,
                      isLoading: isLoading,
                      signInTriggered: signInTriggered,
                      appleSigninTriggered: appleLoginBtnTrigger,
                      session: session,
                      error: errorRelay)
    }
}

extension LoginViewModel {
    private func loginWithEmailAndPassword(email: String, password: String) async throws -> Session {
        return try await supabaseManager.signinWithEmailAndPassword(email: email,
                                                                     password: password)
    }
    
    func appleLogin(token: String) async throws -> Session {
        return try await supabaseManager.signInWithApple(token: token)
    }
}
