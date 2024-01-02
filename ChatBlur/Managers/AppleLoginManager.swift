//
//  AppleLoginManager.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/2/24.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import AuthenticationServices

final class AppleLoginManager: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private let loginViewController: UIViewController
    
    let loginToken: PublishRelay<String> = PublishRelay<String>()
    let loginError: PublishRelay<Error> = PublishRelay<Error>()
    
    init(loginViewController: UIViewController) {
        self.loginViewController = loginViewController
    }
    
    deinit {
        print("AppleLoginManager Deinit")
    }
    
    func authorize() {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = self.loginViewController.view.window else {
            return ASPresentationAnchor(frame: self.loginViewController.view.frame)
        }
        return window
    }
    
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            self.saveUserInKeychain(userIdentifier)
            
            guard let idToken = appleIDCredential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }) else {
                return
            }
            self.loginToken.accept(idToken)
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
//            DispatchQueue.main.async {
//                self.showPasswordCredentialAlert(username: username, password: password)
//            }
            
        default:
            break
        }
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.example.apple-samplecode.juice", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
  
    
//    private func showPasswordCredentialAlert(username: String, password: String) {
//        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
//        let alertController = UIAlertController(title: "Keychain Credential Received",
//                                                message: message,
//                                                preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
//        self.present(alertController, animated: true, completion: nil)
//    }
    
    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.loginError.accept(error)
    }

}
