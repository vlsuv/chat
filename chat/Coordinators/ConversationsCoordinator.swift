//
//  ConversationsCoordinator.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class ConversationsCoordinator: Coordinator {
    
    // MARK: - Properties
    private(set) var childCoordinators: [Coordinator] = [Coordinator]()
    
    private let navigationController: UINavigationController
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Handlers
    func start() {
        let conversationsViewModel = ConversationsViewModel()
        conversationsViewModel.coordinator = self
        
        let conversationsController = ConversationsController()
        conversationsController.viewModel = conversationsViewModel
        
        navigationController.viewControllers = [conversationsController]
    }
    
    func childDidFinish(_ childCoordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: { $0 === childCoordinator }) else { return }
        childCoordinators.remove(at: index)
    }
    
    func showLogin() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        loginCoordinator.parentCoordinator = self
        loginCoordinator.start()
        childCoordinators.append(loginCoordinator)
    }
}
