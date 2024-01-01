//
//  LoadingViewController.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/31/23.
//

import UIKit

final class LoadingViewController: UIViewController {

    //MARK: - UI Elements
    private let spinnerBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        view.clipsToBounds = true
        view.layer.cornerRadius = 8.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black.withAlphaComponent(0.5)
        
        self.setUI()
        self.setLayout()
        
        self.activityIndicator.startAnimating()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.activityIndicator.stopAnimating()
        self.navigationItem.hidesBackButton = true
    }
    
}

extension LoadingViewController {
    
    private func setUI() {
        self.view.addSubview(self.spinnerBackground)
        self.spinnerBackground.addSubview(self.activityIndicator)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.spinnerBackground.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.spinnerBackground.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.spinnerBackground.widthAnchor.constraint(equalToConstant: 50),
            self.spinnerBackground.heightAnchor.constraint(equalToConstant: 50),
            
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.spinnerBackground.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.spinnerBackground.centerYAnchor)
        ])
    }
    
}
