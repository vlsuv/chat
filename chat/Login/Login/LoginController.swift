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
    
    var coordinator: LoginCoordinator?
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
        configureNavigationController()
        setupTargets()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        coordinator?.viewDidDisappear()
    }
    
    deinit {
        print("Deinit: \(self)")
    }
    
    // MARK: - Targets
    @objc private func didTapSignupButton() {
        coordinator?.showSignup()
    }
    
    @objc private func didTapPasswordLoginButton() {
        coordinator?.didFinishLogin()
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
