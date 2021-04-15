//
//  ChatCoordinator.swift
//  chat
//
//  Created by vlsuv on 09.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class ChatCoordinator: Coordinator {
    
    // MARK: - Properties
    private(set) var childCoordinators: [Coordinator] = [Coordinator]()
    
    private let navigationController: UINavigationController
    
    var parentCoordinator: Coordinator?
    
    let user: AppUser
    let conversation: Conversation?
    
    // MARK: - Init
    init(navigationController: UINavigationController, user: AppUser, conversation: Conversation?) {
        self.navigationController = navigationController
        self.user = user
        self.conversation = conversation
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Handlers
    func start() {
        let chatViewModel = ChatViewModel(otherUser: user, conversation: conversation)
        chatViewModel.coordinator = self
        
        let chatController = ChatController()
        chatController.viewModel = chatViewModel
        
        navigationController.pushViewController(chatController, animated: true)
    }
    
    func viewDidDisappear() {
        parentCoordinator?.childDidFinish(self)
    }
}
