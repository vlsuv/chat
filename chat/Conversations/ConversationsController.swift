//
//  ConversationsController.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class ConversationsController: UIViewController {
    
    // MARK: - Properties
    var coordinator: ConversationsCoordinator?
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        
        configureNavigationController()
    }
    
    // MARK: - Targets
    @objc private func didTapLoginButton() {
        coordinator?.showLogin()
    }
    
    // MARK: - Handlers
    private func configureNavigationController() {
        let loginButton = UIBarButtonItem(title: "Log in", style: .plain, target: self, action: #selector(didTapLoginButton))
        navigationItem.rightBarButtonItem = loginButton
    }
}
