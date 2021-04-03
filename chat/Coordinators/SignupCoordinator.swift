//
//  SignupCoordinator.swift
//  chat
//
//  Created by vlsuv on 03.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class SignupCoordinator: Coordinator {
    
    // MARK: - Properties
    private(set) var childCoordinators: [Coordinator] = [Coordinator]()
    
    var parentCoordinator: Coordinator?
    
    let navigationController: UINavigationController
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("Deinit: \(self)")
    }
    
    // MARK: - Handlers
    func start() {
        let signupController = SignupController()
        signupController.coordinator = self
        navigationController.pushViewController(signupController, animated: true)
    }
    
    func viewDidDisappear() {
        parentCoordinator?.childDidFinish(self)
    }
    
    func didFinishSignup() {
        navigationController.dismiss(animated: false, completion: nil)
        navigationController.viewControllers = []
        parentCoordinator?.childDidFinish(self)
    }
}
