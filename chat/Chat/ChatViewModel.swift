//
//  ChatViewModel.swift
//  chat
//
//  Created by vlsuv on 09.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine
import MessageKit
import FirebaseAuth

protocol ChatViewModelType {
    var title: String { get }
    
    var messagesPublisher: Published<[Message]>.Publisher { get }
    
    func currentSender() -> SenderType
    func messageForItem(atIndexPath indexPath: IndexPath) -> MessageType
    func numberOfSections() -> Int
    
    func sendTextMessage(_ text: String)
    
    func viewDidDisappear()
}

class ChatViewModel: ChatViewModelType {
    
    // MARK: - Properties
    var coordinator: ChatCoordinator?
    
    var title: String {
        return otherUser.displayName
    }
    
    let otherUser: AppUser
    
    var sender: AppUser? {
        guard let currentUser = Auth.auth().currentUser,
            let name = currentUser.displayName,
            let email = currentUser.email else { return nil }
        
        return AppUser(senderId: currentUser.uid, displayName: name, email: email)
    }
    
    var conversation: Conversation? {
        didSet {
            setupObserveForAllMessages()
        }
    }
    
    var isNewChat: Bool {
        return conversation == nil
    }
    
    @Published var messages: [Message] = [Message]()
    var messagesPublisher: Published<[Message]>.Publisher { $messages }
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(otherUser: AppUser, conversation: Conversation?) {
        self.otherUser = otherUser
        
        defer {
            self.conversation = conversation
        }
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Handlers
    func currentSender() -> SenderType {
        return sender ?? AppUser(senderId: "", displayName: "", email: "")
    }
    
    func messageForItem(atIndexPath indexPath: IndexPath) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections() -> Int {
        return messages.count
    }
    
    func viewDidDisappear() {
        coordinator?.viewDidDisappear()
    }
    
    private func setupObserveForAllMessages() {
        guard let conversationId = conversation?.id else { return }
        
        DatabaseManager.shared.observeForAllMesages(conversationId: conversationId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                self?.messages = messages
        }
        .store(in: &cancellables)
    }
}

extension ChatViewModel {
    func sendTextMessage(_ text: String) {
        guard let sender = sender else { return }
        
        let message = Message(messageId: generateMessageId(),
                              sentDate: Date(),
                              kind: .text(text),
                              user: sender)
        
        if isNewChat {
            createConversation(withMessage: message)
        } else {
            sendMessageToExistConversation(withMessage: message)
        }
    }
    
    private func createConversation(withMessage message: Message) {
        DatabaseManager.shared.createConversation(otherUser: otherUser, message: message)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }) { [weak self] newConversation in
                self?.conversation = newConversation
        }
        .store(in: &cancellables)
    }
    
    private func sendMessageToExistConversation(withMessage message: Message) {
        guard let conversation = conversation else { return }
        
        DatabaseManager.shared.sendMessage(to: conversation, message: message)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }) { _ in
                print("Message send")
        }
        .store(in: &cancellables)
    }
    
    private func generateMessageId() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .long
        dateFormatter.dateStyle = .medium
        return "\(sender!.senderId)_\(otherUser.senderId)_\(dateFormatter.string(from: Date()))"
    }
}
