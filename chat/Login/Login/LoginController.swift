//
//  LoginController.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    // MARK: - Properties
    private var contentView: LoginView!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
        configureNavigationController()
        setupTargets()
    }
    
    deinit {
        print("Deinit: \(self)")
    }
    
    // MARK: - Targets
    @objc private func didTapSignupButton() {
        let signupController = SignupController()
        navigationController?.pushViewController(signupController, animated: true)
    }
    
    @objc private func didTapPasswordLoginButton() {
        print("handle log in")
    }
    
    // MARK: - Handlers
    private func setupContentView() {
        contentView = LoginView(frame: view.bounds)
        view.addSubview(contentView)
    }
    
    private func configureNavigationController() {
        let signupButton = UIBarButtonItem(title: "Sign up", style: .plain, target: self, action: #selector(didTapSignupButton))
        navigationItem.rightBarButtonItem = signupButton
    }
    
    private func setupTargets() {
        contentView.passwordLoginButton.addTarget(self, action: #selector(didTapPasswordLoginButton), for: .touchUpInside)
    }
}
