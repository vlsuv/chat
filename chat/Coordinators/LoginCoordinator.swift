//
//  LoginCoordinator.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class LoginCoordinator: Coordinator {
    
    // MARK: - Properties
    private(set) var childCoordinators: [Coordinator] = [Coordinator]()
    
    var parentCoordinator: Coordinator?
    
    private let navigationController: UINavigationController
    private var modalNavigationController: UINavigationController?
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("Deinit: \(self)")
    }
    
    // MARK: - Handlers
    func start() {
        let loginViewModel = LoginViewModel()
        loginViewModel.coordinator = self
        
        let loginController = LoginController()
        loginController.viewModel = loginViewModel
        
        modalNavigationController = UINavigationController()
        modalNavigationController?.modalPresentationStyle = .fullScreen
        modalNavigationController?.viewControllers = [loginController]
        
        if let modalNavigationController = modalNavigationController {
            navigationController.present(modalNavigationController, animated: true, completion: nil)
        }
    }
    
    func childDidFinish(_ childCoordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: { $0 === childCoordinator }) else { return }
        childCoordinators.remove(at: index)
    }
    
    func viewDidDisappear() {
        parentCoordinator?.childDidFinish(self)
    }
    
    func showSignup() {
        guard let modalNavigationController = modalNavigationController else { return }
        
        let signupCoordinator = SignupCoordinator(navigationController: modalNavigationController)
        signupCoordinator.parentCoordinator = self
        signupCoordinator.start()
        childCoordinators.append(signupCoordinator)
    }
    
    func didFinishLogin() {
        modalNavigationController?.dismiss(animated: false, completion: nil)
        modalNavigationController?.viewControllers = []
        parentCoordinator?.childDidFinish(self)
    }
}
