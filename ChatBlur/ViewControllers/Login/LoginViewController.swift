//
//  LoginViewController.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/27/23.
//

import UIKit
import FlexLayout
import PinLayout
import AuthenticationServices
import UIKitBooster
import RxCocoa
import RxSwift

final class LoginViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    
    //MARK: - View Model
    private let vm: LoginViewModel
    
    //MARK: - UI Elements
    private let loadingVC: LoadingViewController = LoadingViewController()
    
    private let flexContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .frenchie5)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let emailTextField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = LoginViewConstants.email
        field.backgroundColor = .systemBackground
        return field
    }()
    
    private let pwdTextField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = LoginViewConstants.password
        field.backgroundColor = .systemBackground
        return field
    }()
    
    private let findPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle(LoginViewConstants.findPassword, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: AppFont.small)
        button.setTitleColor(.secondaryText, for: .normal)
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .buttonDeactivated
        button.setTitle(LoginViewConstants.login, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: AppFont.normal)
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        button.setTitleColor(.buttonActivated, for: .normal)
        return button
    }()
    
    // Apple login
    private let appleLoginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        return button
    }()
    
    private let orLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.text = LoginViewConstants.or
        label.textColor = .secondaryText
        return label
    }()
    
    private let kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.setTitle(LoginViewConstants.kakao, for: .normal)
        button.backgroundColor = .systemBlue
        button.clipsToBounds = true
        button.layer.cornerRadius = 6
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private let signupLabel: UILabel = {
        let label = UILabel()
        label.text = LoginViewConstants.createNewAccount
        label.font = .systemFont(ofSize: AppFont.small)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let signupButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(LoginViewConstants.signup, for: .normal)
        btn.setTitleColor(.buttonActivated, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: AppFont.normal)
        return btn
    }()
    
    //MARK: - Init
    init(vm: LoginViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .background
        self.dismissKeyboard()
        
        self.setUI()
        self.setLayout()
        
        self.bind(with: self.vm)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setFlexContainer()
    }
}

extension LoginViewController {
    private func bind(with vm: LoginViewModel) {
        
        self.signupButton.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                guard let `self` = self else { return }
                self.showSignupVC()
            }
            .disposed(by: disposeBag)
        
        let input = LoginViewModel.Input(
            email: self.emailTextField.rx.text.orEmpty.asObservable(),
            password: self.pwdTextField.rx.text.orEmpty.asObservable(),
            emailLoginBtnTrigger: self.loginButton.rx.tap.asObservable(),
            appleLoginBtnTrigger: self.appleLoginButton.rx.tap.map {                 return self
            }.asObservable())
        
        let output = self.vm.transform(input: input)
            
        output.shouldActivate
            .drive { [weak self] isActive in
                guard let `self` = self else { return }
                self.loginButton.isEnabled = isActive
                self.loginButton.backgroundColor = isActive ? .buttonActivated : .buttonDeactivated
                self.loginButton.setTitleColor(
                    isActive ? .buttonActivatedTitle : .buttonDeactivatedTitle,
                                               for: .normal
                )
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .distinctUntilChanged()
            .subscribe (onNext: { [weak self] loading in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    loading ? self.addChildViewController(self.loadingVC) : self.loadingVC.removeViewController()
                }
                
            })
            .disposed(by: disposeBag)
        
        output.session
            .subscribe (onNext: { [weak self] session in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    let vm = TabbarViewModel(session: session)
                    self.show(
                        MainTabbarViewController(vm: vm),
                        sender: self
                    )
                }
            })
            .disposed(by: disposeBag)
        
        output.error
            .subscribe(onNext: { [weak self] error in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.loadingVC.removeViewController()
                    self.showAlert(title: ErrorConstants.errorTitle,
                                   msg: ErrorConstants.errorMsg + "\(error.localizedDescription)",
                                   action1: UIAlertAction(title: ErrorConstants.confirm, style: .cancel))
                }
            })
            .disposed(by: disposeBag)
            
        output.signInTriggered
            .subscribe()
            .disposed(by: disposeBag)
        
        output.appleSigninTriggered
            .subscribe()
            .disposed(by: disposeBag)
    }
}

extension LoginViewController {
    private func setUI() {
        self.view.addSubview(self.flexContainer)
    }
    
    private func setFlexContainer() {
        self.flexContainer.pin.all(self.view.pin.safeArea)
        self.flexContainer.flex.layout()
    }
    
    private func setLayout() {
        let eleWidth = self.view.frame.width / 1.5
        let eleHeight = 40.0
        
        self.flexContainer.flex
            .direction(.column)
            .define { flex in
                flex.addItem(self.logoImageView)
                    .aspectRatio(of: self.logoImageView)
                    .marginTop(20%)
                    .width(self.view.frame.width / 2)
                    .height(self.view.frame.width / 2)
                
                
                flex.addItem(self.emailTextField)
                    .marginTop(10%)
                    .width(eleWidth)
                
                flex.addItem(self.pwdTextField)
                    .marginTop(2%)
                    .width(eleWidth)
                
                flex.addItem(self.findPasswordButton)
                    .width(150)
                    .marginTop(2%)
                    .alignSelf(.end)
                    .marginRight(9%)
                
                flex.addItem(self.loginButton)
                    .marginTop(2%)
                    .height(eleHeight)
                    .width(eleWidth/2)
                
                flex.addItem()
                    .direction(.row)
                    .define { flex in
                        flex.addItem()
                            .height(1)
                            .width(30%)
                            .backgroundColor(.secondaryText)
                        flex.addItem(self.orLabel)
                            .width(50)
                        flex.addItem()
                            .height(1)
                            .width(30%)
                            .backgroundColor(.secondaryText)
                    }
                    .alignItems(.center)
                    .marginTop(5%)
                
                flex.addItem(self.appleLoginButton)
                    .marginTop(10%)
                    .height(eleHeight)
                    .width(eleWidth)
                
                flex.addItem(self.kakaoLoginButton)
                    .marginTop(2%)
                    .height(eleHeight)
                    .width(eleWidth)
                
                flex.addItem()
                    .direction(.row)
                    .define { flex in
                        flex.addItem(self.signupLabel)
                            .marginRight(5%)
                        flex.addItem(self.signupButton)
                    }
                    .marginTop(5%)
                
            }
            .alignItems(.center)
    }
}

extension LoginViewController {
    private func showSignupVC() {
        let vm = SignupViewModel()
        let vc = SignupViewController(vm: vm)
        self.show(vc, sender: self)
    }
}

@available(iOS 17, *)
#Preview(nil,
         traits: .defaultLayout,
         body: {
    LoginViewController(vm: LoginViewModel())
})
