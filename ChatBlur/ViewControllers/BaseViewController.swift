//
//  BaseViewController.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/1/24.
//

import UIKit

class BaseViewController: UIViewController {

    typealias Handler = () -> ()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension BaseViewController {
    func showAlert(title: String,
                   msg: String,
                   action1: UIAlertAction,
                   action2: UIAlertAction? = nil) {
        
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: .alert)
        
        alert.addAction(action1)
        if let action2 {
            alert.addAction(action2)
        }
        
        self.present(alert, animated: true)
    }
}
