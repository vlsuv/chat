//
//  SignupController.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class SignupController: UIViewController {
    
    // MARK: - Properties
    private var contentView: SignupView!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentView()
        setupTargets()
    }
    
    deinit {
        print("Deinit: \(self)")
    }
    
    // MARK: - Targets
    @objc private func didTapSignupButton() {
        print("handle sign up")
    }
    
    // MARK: - Handlers
    private func setupContentView() {
        contentView = SignupView(frame: view.bounds)
        view.addSubview(contentView)
    }
    
    private func setupTargets() {
        contentView.signupButton.addTarget(self, action: #selector(didTapSignupButton), for: .touchUpInside)
    }
}
