//
//  ConversationsViewModel.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import FirebaseAuth
import Combine

protocol ConversationsViewModelType {
    func numberOfRows() -> Int
    func conversationCellViewModel(forIndexPath indexPath: IndexPath) -> ConversationCellViewModelType?
    
    func didTapNewMessage()
    func didSelectChat(atIndexPath indexPath: IndexPath)
    
    var conversationsPublisher: Published<[Conversation]>.Publisher { get }
}

class ConversationsViewModel: ConversationsViewModelType {
    
    // MARK: - Properties
    weak var coordinator: ConversationsCoordinator?
    
    @Published var conversations: [Conversation] = [Conversation]()
    var conversationsPublisher: Published<[Conversation]>.Publisher { $conversations }
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init() {
        setupObserveForAllConversations()
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Handlers
    func numberOfRows() -> Int {
        return conversations.count
    }
    
    func conversationCellViewModel(forIndexPath indexPath: IndexPath) -> ConversationCellViewModelType? {
        let conversation = conversations[indexPath.row]
        return ConversationCellViewModel(conversation: conversation)
    }
    
    func didTapNewMessage() {
        coordinator?.showNewMessage()
    }
    
    func didSelectChat(atIndexPath indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        
        coordinator?.showChat(withUser: conversation.otherUser, conversation: conversation)
    }
    
    private func setupObserveForAllConversations() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        DatabaseManager.shared.observeForAllConversations(userUid: currentUser.uid)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] conversations in
                self?.conversations = conversations
            })
            .store(in: &cancellables)
    }
}
