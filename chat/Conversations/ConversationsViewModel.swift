//
//  ConversationsViewModel.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

protocol ConversationsViewModelType {
    func showLogin()
    
    func numberOfRows() -> Int
    func conversationCellViewModel(forIndexPath indexPath: IndexPath) -> ConversationCellViewModelType?
}

class ConversationsViewModel: ConversationsViewModelType {
    
    // MARK: - Properties
    var coordinator: ConversationsCoordinator?
    
    var conversations: [String] = ["foo", "foo"]
    
    // MARK: - Init
    func showLogin() {
        coordinator?.showLogin()
    }
    
    func numberOfRows() -> Int {
        return conversations.count
    }
    
    func conversationCellViewModel(forIndexPath indexPath: IndexPath) -> ConversationCellViewModelType? {
        let conversation = conversations[indexPath.row]
        return ConversationCellViewModel(conversation: conversation)
    }
}
