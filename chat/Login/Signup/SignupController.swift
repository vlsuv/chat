//
//  SignupController.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine

class SignupController: UIViewController {
    
    // MARK: - Properties
    private var contentView: SignupView!
    
    var viewModel: SignupViewModelType!
    
    var store = Set<AnyCancellable>()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
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
        viewModel?.handleSignup()
    }
    
    // MARK: - Handlers
    private func setupContentView() {
        contentView = SignupView(frame: view.bounds)
        view.addSubview(contentView)
    }
    
    private func setupTargets() {
        contentView.signupButton.addTarget(self, action: #selector(didTapSignupButton), for: .touchUpInside)
    }
    
    private func setupBindings() {
        contentView.nameTextField
            .textPublisher
            .assign(to: \.name, on: viewModel)
            .store(in: &store)
        
        contentView.emailTextField
            .textPublisher
            .assign(to: \.email, on: viewModel)
            .store(in: &store)
        
        contentView.passwordTextField
            .textPublisher
            .assign(to: \.password, on: viewModel)
            .store(in: &store)
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.contentView.activityIndicator.startAnimating()
                } else {
                    self?.contentView.activityIndicator.stopAnimating()
                }
        }
        .store(in: &store)
    }
}
