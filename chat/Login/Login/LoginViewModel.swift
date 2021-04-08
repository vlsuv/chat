//
//  LoginViewModel.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine
import FirebaseAuth
import GoogleSignIn

protocol LoginViewModelType: class {
    var email: String { get set }
    var password: String { get set }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    
    func viewDidDisappear()
    func showSignup()
    func handlePasswordLogin()
}

class LoginViewModel: NSObject, LoginViewModelType {
    
    // MARK: - Properties
    var coordinator: LoginCoordinator?
    
    var email: String = ""
    var password: String = ""
    
    @Published var isLoading: Bool = false
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    override init() {
        super.init()
        
        GIDSignIn.sharedInstance().delegate = self
    }
    
    // MARK: - Handlers
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

// MARK: - GIDSignInDelegate
extension LoginViewModel: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        isLoading = true
        
        if let error = error {
            print(error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print(error)
                return
            }
            
            guard let result = result else { return }
            
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = user.profile.name
            changeRequest.commitChanges { error in
                if let error = error {
                    print(error)
                    return
                }
            }
            
            let googleUser = AppUser(name: user.profile.name,
                                  email: user.profile.email,
                                  uid: result.user.uid)
            
            DatabaseManager.shared.existUser(withUid: googleUser.uid).sink(receiveCompletion: { _ in
            }) { [weak self] isExist in
                if isExist {
                    self?.isLoading = false
                    self?.coordinator?.didFinishLogin()
                } else {
                    self?.insertGoogleUserIntoDatabase(googleUser)
                }
            }.store(in: &self.cancellables)
        }
    }
    
    private func insertGoogleUserIntoDatabase(_ user: AppUser) {
        DatabaseManager.shared.insertUserIntoDatabase(user).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print(error)
            }
        }) { [weak self] _ in
            self?.isLoading = false
            self?.coordinator?.didFinishLogin()
        }
        .store(in: &cancellables)
    }
}
