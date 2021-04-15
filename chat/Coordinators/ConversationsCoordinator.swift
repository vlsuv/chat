//
//  ConversationsCoordinator.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

protocol ConversationsCoordinatorProtocol: Coordinator {
   func showChat(withUser user: AppUser, conversation: Conversation?)
}

class ConversationsCoordinator: ConversationsCoordinatorProtocol {
    
    // MARK: - Properties
    private(set) var childCoordinators: [Coordinator] = [Coordinator]()
    
    private let navigationController: UINavigationController
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("deinit: \(self)")
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
    
    func showNewMessage() {
        let newMessageCoordinator = NewMessageCoordinator(navigationController: navigationController)
        newMessageCoordinator.parentCoordinator = self
        newMessageCoordinator.start()
        childCoordinators.append(newMessageCoordinator)
    }
    
    func showChat(withUser user: AppUser, conversation: Conversation?) {
        let chatCoordinator = ChatCoordinator(navigationController: navigationController, user: user, conversation: conversation)
        chatCoordinator.parentCoordinator = self
        chatCoordinator.start()
        childCoordinators.append(chatCoordinator)
    }
}
