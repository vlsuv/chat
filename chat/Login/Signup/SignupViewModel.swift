//
//  SignupViewModel.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

protocol SignupViewModelType {
    func viewDidDisappear()
    func handleSignup()
}

class SignupViewModel: SignupViewModelType {
    
    // MARK: - Properties
    var coordinator: SignupCoordinator?
    
    // MARK: - Init
    func viewDidDisappear() {
        coordinator?.viewDidDisappear()
    }
    
    func handleSignup() {
        coordinator?.didFinishSignup()
    }
    
}
