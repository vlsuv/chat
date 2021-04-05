//
//  LoginViewModel.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

protocol LoginViewModelType {
    func viewDidDisappear()
    func showSignup()
    func handlePasswordLogin()
}

class LoginViewModel: LoginViewModelType {
    
    // MARK: - Properties
    var coordinator: LoginCoordinator?
    
    // MARK: - Init
    func viewDidDisappear() {
        coordinator?.viewDidDisappear()
    }
    
    func showSignup() {
        coordinator?.showSignup()
    }
    
    func handlePasswordLogin() {
        coordinator?.didFinishLogin()
    }
}
