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
    var title: String { get }
    
    func numberOfRows() -> Int
    func conversationCellViewModel(forIndexPath indexPath: IndexPath) -> ConversationCellViewModelType?
    
    func didTapNewMessage()
    func didSelectChat(atIndexPath indexPath: IndexPath)
    
    var conversationsPublisher: Published<[Conversation]>.Publisher { get }
    
    func deleteConversation(atIndexPath indexPath: IndexPath)
}

class ConversationsViewModel: ConversationsViewModelType {
    
    // MARK: - Properties
    var title: String {
        return "Chats"
    }
    
    weak var coordinator: ConversationsCoordinator?
    
    var user: AppUser? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentUser = appDelegate.currentUser else { return nil }
        
        return currentUser
    }
    
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
        guard let user = user else { return }
        
        DatabaseManager.shared.observeForAllConversations(user: user)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }) { [weak self] conversations in
                self?.conversations = conversations
        }
        .store(in: &cancellables)
    }
    
    func deleteConversation(atIndexPath indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentUser = appDelegate.currentUser else { return }
        
        let conversation = conversations[indexPath.row]
        
        DatabaseManager.shared.deleteConversation(conversation, user: currentUser)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }) { _ in
                print("conversation deleted")
        }
        .store(in: &cancellables)
    }
}
