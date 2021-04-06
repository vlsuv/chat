//
//  LoginViewModel.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol LoginViewModelType: class {
    var email: String { get set }
    var password: String { get set }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    
    func viewDidDisappear()
    func showSignup()
    func handlePasswordLogin()
}

class LoginViewModel: LoginViewModelType {
    
    // MARK: - Properties
    var coordinator: LoginCoordinator?
    
    var email: String = ""
    var password: String = ""
    
    @Published var isLoading: Bool = false
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    
    // MARK: - Init
    func viewDidDisappear() {
        coordinator?.viewDidDisappear()
    }
    
    func showSignup() {
        coordinator?.showSignup()
    }
    
    func handlePasswordLogin() {
        guard email != "", password != "", !email.isEmpty, !password.isEmpty else { return }
        
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print(error)
                return
            }
            
            guard result != nil else { return }
            
            self?.isLoading = false
            self?.coordinator?.didFinishLogin()
        }
    }
}
