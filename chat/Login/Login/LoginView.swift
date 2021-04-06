//
//  LoginView.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class LoginView: UIView {
    
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
    
    var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.layer.borderWidth = 2
        textField.layer.borderColor = Color.lightGray.cgColor
        textField.layer.cornerRadius = 10
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = true
        textField.layer.borderWidth = 2
        textField.layer.borderColor = Color.lightGray.cgColor
        textField.layer.cornerRadius = 10
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    var passwordLoginButton: UIButton = {
       let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(Color.white, for: .normal)
        button.backgroundColor = Color.black
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
        emailTextField.frame = CGRect(x: scrollView.left + 30,
                                      y: scrollView.top + 30,
                                      width: scrollView.width - 60,
                                      height: 52)
        passwordTextField.frame = CGRect(x: emailTextField.left,
                                         y: emailTextField.bottom + 10,
                                         width: emailTextField.width,
                                         height: emailTextField.height)
        passwordLoginButton.frame = CGRect(x: scrollView.left + 30,
                                           y: passwordTextField.bottom + 10,
                                           width: scrollView.width - 60,
                                           height: 52)
    }
    
    // MARK: - Handlers
    private func setupSubviews() {
        self.addSubview(scrollView)
        [activityIndicator, emailTextField, passwordTextField, passwordLoginButton].forEach { scrollView.addSubview($0) }
    }
}
