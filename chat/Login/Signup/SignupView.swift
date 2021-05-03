//
//  SignupView.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class SignupView: UIView {
    
    // MARK: - Properties
    var scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        return scrollView
    }()
    
    var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = Color.black
        ai.hidesWhenStopped = true
        return ai
    }()
    
    var nameTextField: LoginTextField = {
        let textField = LoginTextField(frame: .zero, name: "name")
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()
    
    var emailTextField: LoginTextField = {
        let textField = LoginTextField(frame: .zero, name: "email")
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()
    
    var passwordTextField: LoginTextField = {
        let textField = LoginTextField(frame: .zero, name: "password")
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = true
        return textField
    }()
    
    var signupButton: UIButton = {
        let button = UIButton()
        let normalAttributedTitle = NSAttributedString(string: "Sign up", attributes: [
            NSAttributedString.Key.foregroundColor: Color.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ])
        button.setAttributedTitle(normalAttributedTitle, for: .normal)
        button.backgroundColor = Color.basicBlue
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Color.white
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = self.bounds
        activityIndicator.center = self.center
        nameTextField.frame = CGRect(x: scrollView.left + 30,
                                     y: scrollView.top + 30,
                                     width: scrollView.width - 60,
                                     height: 52)
        emailTextField.frame = CGRect(x: nameTextField.left,
                                      y: nameTextField.bottom + 10,
                                      width: nameTextField.width,
                                      height: nameTextField.height)
        passwordTextField.frame = CGRect(x: emailTextField.left,
                                         y: emailTextField.bottom + 10,
                                         width: nameTextField.width,
                                         height: nameTextField.height)
        signupButton.frame = CGRect(x: scrollView.left + 30,
                                    y: passwordTextField.bottom + 10,
                                    width: scrollView.width - 60,
                                    height: 52)
        signupButton.layer.cornerRadius = 10
    }
    
    // MARK: - Handlers
    private func setupSubviews() {
        self.addSubview(scrollView)
        [activityIndicator, nameTextField, emailTextField, passwordTextField, signupButton].forEach{ scrollView.addSubview($0) }
    }
    
    
}
