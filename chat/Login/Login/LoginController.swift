//
//  LoginController.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine

class LoginController: UIViewController {
    
    // MARK: - Properties
    private var contentView: LoginView!
    
    var viewModel: LoginViewModelType!
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
        configureNavigationController()
        setupTargets()
        setupBindings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.viewDidDisappear()
    }
    
    deinit {
        print("Deinit: \(self)")
    }
    
    // MARK: - Targets
    @objc private func didTapSignupButton() {
        viewModel?.showSignup()
    }
    
    @objc private func didTapPasswordLoginButton() {
        viewModel?.handlePasswordLogin()
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
    
    private func setupBindings() {
        contentView.emailTextField
            .textPublisher
            .assign(to: \.email, on: viewModel)
            .store(in: &cancellables)
        
        contentView.passwordTextField
            .textPublisher
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.contentView.activityIndicator.startAnimating()
                } else {
                    self?.contentView.activityIndicator.stopAnimating()
                }
        }
        .store(in: &cancellables)
    }
}
