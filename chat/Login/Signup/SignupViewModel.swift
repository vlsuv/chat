//
//  SignupViewModel.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine
import FirebaseAuth

protocol SignupViewModelType: class {
    var name: String { get set }
    var email: String { get set }
    var password: String { get set }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    
    func viewDidDisappear()
    func handleSignup()
}

class SignupViewModel: SignupViewModelType {
    
    // MARK: - Properties
    var coordinator: SignupCoordinator?
    
    var name: String = ""
    var email: String = ""
    var password: String = ""
    
    @Published var isLoading: Bool = false
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    func viewDidDisappear() {
        coordinator?.viewDidDisappear()
    }
    
    func handleSignup() {
        guard name != "", email != "", password != "",
            !name.isEmpty, !email.isEmpty, !password.isEmpty else {
                return
        }
        
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print(error)
                return
            }
            
            guard let result = result else { return }
            
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = self.name
            changeRequest.commitChanges { error in
                if let error = error {
                    print(error)
                    return
                }
            }
            
            let user = User(name: self.name,
                            email: self.email,
                            uid: result.user.uid)
            
            DatabaseManager.shared.insertUserIntoDatabase(user)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(error)
                    }
                }) { [weak self] _ in
                    self?.isLoading = false
                    self?.coordinator?.didFinishSignup()
            }
            .store(in: &self.cancellables)
        }
    }
}
