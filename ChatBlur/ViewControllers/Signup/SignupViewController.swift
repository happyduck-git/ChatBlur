//
//  SignupViewController.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/30/23.
//

import UIKit
import FlexLayout
import PinLayout
import RxCocoa
import RxSwift

final class SignupViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    
    private let vm: SignupViewModel
    
    //MARK: - UI Elements
    
    private let loadingVC: LoadingViewController = LoadingViewController()
    
    private let flexContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = SignupConstants.username
        textField.keyboardType = .alphabet
        textField.layer.cornerRadius = 6.0
        textField.layer.borderColor = UIColor.buttonDeactivated.cgColor
        textField.layer.borderWidth = 1.0
        textField.tag = 0
        return textField
    }()
    
    private let usernameValidationLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = SignupConstants.invalidUsername
        label.textColor = .systemRed
        label.textAlignment = .left
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: AppFont.small)
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = SignupConstants.email
        textField.keyboardType = .emailAddress
        textField.layer.cornerRadius = 6.0
        textField.layer.borderColor = UIColor.buttonDeactivated.cgColor
        textField.layer.borderWidth = 1.0
        textField.tag = 1
        return textField
    }()
    
    private let emailValidationLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = SignupConstants.invalidEmail
        label.textColor = .systemRed
        label.textAlignment = .left
        label.font = .systemFont(ofSize: AppFont.small)
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = SignupConstants.password
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 6.0
        textField.layer.borderColor = UIColor.buttonDeactivated.cgColor
        textField.layer.borderWidth = 1.0
        textField.tag = 2
        return textField
    }()
    
    private let passwordValidationLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = SignupConstants.invalidPassword
        label.textColor = .systemRed
        label.textAlignment = .left
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: AppFont.small)
        return label
    }()
    
    private let passwordCheckTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = SignupConstants.passwordCheck
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 6.0
        textField.layer.borderColor = UIColor.buttonDeactivated.cgColor
        textField.layer.borderWidth = 1.0
        textField.tag = 3
        return textField
    }()
    
    private let passwordCheckValidationLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = SignupConstants.passwordMissmatch
        label.textColor = .systemRed
        label.textAlignment = .left
        label.font = .systemFont(ofSize: AppFont.small)
        return label
    }()
    
    private let signupButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        button.setTitle(SignupConstants.signup, for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    init(vm: SignupViewModel) {
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
        
        self.setUI()
        self.setLayout()
        self.setNavigationBar()
        self.setTextfieldIcons()
        self.setDelegate()
        self.dismissKeyboard()
        
        self.bind(with: self.vm)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setFlexContainer()
    }
}

extension SignupViewController {
    
    private func bind(with vm: SignupViewModel) {
        
        let input = SignupViewModel.Input(
            username: usernameTextField.rx.text.orEmpty.asObservable(),
            email: emailTextField.rx.text.orEmpty.asObservable(),
            password: passwordTextField.rx.text.orEmpty.asObservable(),
            passwordCheck: passwordCheckTextField.rx.text.orEmpty.asObservable(),
            signupBtnTrigger: signupButton.rx.tap.asObservable()
        )
        
        let output = vm.transform(input: input)
        
        output.isUsernameValid
            .distinctUntilChanged()
            .drive { [weak self] in
                guard let `self` = self else { return }
                self.usernameValidationLabel.isHidden = $0 ? true : false
            }
            .disposed(by: disposeBag)
        
        output.isEmailValid
            .distinctUntilChanged()
            .drive { [weak self] in
                guard let `self` = self else { return }
                self.emailValidationLabel.isHidden = $0 ? true : false
            }
            .disposed(by: disposeBag)
        
        output.isPasswordValid
            .distinctUntilChanged()
            .drive { [weak self] in
                guard let `self` = self else { return }
                self.passwordValidationLabel.isHidden = $0 ? true : false
            }
            .disposed(by: disposeBag)
        
        output.isSamePassword
            .distinctUntilChanged()
            .drive { [weak self] in
                guard let `self` = self else { return }
                self.passwordCheckValidationLabel.isHidden = $0 ? true : false
            }
            .disposed(by: disposeBag)
        
        output.activateSignup
            .distinctUntilChanged()
            .drive { [weak self] in
                guard let `self` = self else { return }
                
                self.signupButton.isUserInteractionEnabled = $0 ? true : false
                self.signupButton.backgroundColor = $0 ? .buttonActivated : .buttonDeactivated
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .distinctUntilChanged()
            .subscribe (onNext: { [weak self] loading in
                guard let `self` = self else { return }
                
                DispatchQueue.main.async {
                    loading ? self.addChildViewController(self.loadingVC) : self.loadingVC.removeViewController()
                    if !loading {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            })
            .disposed(by: disposeBag)
        
        output.error
            .subscribe(onNext: { [weak self] error in
                guard let `self` = self else { return }
                
                DispatchQueue.main.async {
                    self.loadingVC.removeViewController()
                    self.showAlert(title: SignupConstants.errorTitle,
                                   msg: SignupConstants.errorMsg + "\(error.localizedDescription)",
                                   action1: UIAlertAction(title: SignupConstants.confirm, style: .cancel))
                }
                
            }).disposed(by: disposeBag)
        
        output.signupTriggered
            .subscribe()
            .disposed(by: disposeBag)
    }
}

extension SignupViewController {
    
    private func setDelegate() {
        self.usernameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.passwordCheckTextField.delegate = self
    }
    
    private func setNavigationBar() {
        self.title = SignupConstants.signup
    }
    
    private func setUI() {
        self.view.addSubview(self.flexContainer)
    }
    
    private func setFlexContainer() {
        self.flexContainer.pin.all(self.view.pin.safeArea)
        self.flexContainer.flex.layout()
        
        self.usernameValidationLabel.pin.left(self.usernameTextField.frame.minX)
        self.emailValidationLabel.pin.left(self.emailTextField.frame.minX)
        self.passwordValidationLabel.pin
            .left(self.passwordTextField.frame.minX)
        self.passwordCheckValidationLabel.pin.left(self.passwordCheckTextField.frame.minX)
    }
    
    private func setLayout() {
        let eleWidth = self.view.frame.width / 1.5
        let eleHeight = 40.0
        
        self.flexContainer.flex
            .direction(.column)
            .define { flex in
                flex.addItem(self.usernameTextField)
                    .width(eleWidth)
                    .height(eleHeight)
                    .marginTop(20%)
                
                flex.addItem(self.usernameValidationLabel)
                    .width(eleWidth)
                    .marginTop(5)
                
                flex.addItem(self.emailTextField)
                    .width(eleWidth)
                    .height(eleHeight)
                    .marginTop(5%)
                
                flex.addItem(self.emailValidationLabel)
                    .marginTop(5)
                
                flex.addItem(self.passwordTextField)
                    .width(eleWidth)
                    .height(eleHeight)
                    .marginTop(5%)
                
                flex.addItem(self.passwordValidationLabel)
                    .width(eleWidth)
                    .marginTop(5)
                
                flex.addItem(self.passwordCheckTextField)
                    .width(eleWidth)
                    .height(eleHeight)
                    .marginTop(5%)
                
                flex.addItem(self.passwordCheckValidationLabel)
                    .marginTop(5)
                
                flex.addItem(self.signupButton)
                    .width(eleWidth)
                    .height(eleHeight)
                    .marginTop(20%)
            }
            .alignItems(.center)
    }
    
}

//MARK: - Make TextField Icons
extension SignupViewController {
    
    enum TextFieldType: CaseIterable {
        case username
        case email
        case password
        case passwordCheck
        
        var leftIcon: String {
            switch self {
            case .username:
                "person.circle"
            case .email:
                "envelope"
            case .password, .passwordCheck:
                "lock"
            }
        }
        
        var rightIcon: String {
            switch self {
            case .password, .passwordCheck:
                "eye.slash"
            default:
                String()
            }
        }
    }
    
    private func setTextfieldIcons() {
        self.usernameTextField.leftViewMode = .always
        self.emailTextField.leftViewMode = .always
        self.passwordTextField.leftViewMode = .always
        self.passwordCheckTextField.leftViewMode = .always
        self.passwordTextField.rightViewMode = .always
        self.passwordCheckTextField.rightViewMode = .always
        
        let textFields: [TextFieldType] = TextFieldType.allCases
        let iconPosition = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        for textField in textFields {
            let container = self.makeLeftIconView(
                image: UIImage(systemName: textField.leftIcon)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal),
                at: iconPosition
            )
            
            switch textField {
            case .username:
                self.usernameTextField.leftView = container
            case .email:
                self.emailTextField.leftView = container
            case .password:
                self.passwordTextField.leftView = container
                self.passwordTextField.rightView = self.makeLeftIconView(
                    image: UIImage(systemName: textField.rightIcon)?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal),
                    at: iconPosition
                )
                
            case .passwordCheck:
                self.passwordCheckTextField.leftView = container
                self.passwordCheckTextField.rightView = self.makeLeftIconView(
                    image: UIImage(systemName: textField.rightIcon)?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal),
                    at: iconPosition
                )
            }
        }
        
    }
    
    private func makeLeftIconView(image: UIImage?, at frame: CGRect) -> UIView {
        let container: UIView = UIView()
        container.frame = frame
        
        let padding: CGFloat = 2
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: padding,
                                 y: padding,
                                 width: container.frame.width - 2*padding,
                                 height: container.frame.width - 2*padding)
        imageView.image = image
        
        container.addSubview(imageView)
        
        return container
    }
}

extension SignupViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.setBorderColorsToTextFields(textField, true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.setBorderColorsToTextFields(textField, false)
    }
    
    private func setBorderColorsToTextFields(_ textField: UITextField, _ activate: Bool) {
        switch textField.tag {
        case 0:
            self.usernameTextField.setTextFieldBorderColor(activate)
        case 1:
            self.emailTextField.setTextFieldBorderColor(activate)
        case 2:
            self.passwordTextField.setTextFieldBorderColor(activate)
        case 3:
            self.passwordCheckTextField.setTextFieldBorderColor(activate)
        default:
            return
        }
    }
}

@available(iOS 17, *)
#Preview(nil,
         traits: .defaultLayout,
         body: {
    SignupViewController(vm: SignupViewModel())
})
