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
    
    func didTapAttachmentButton()
    
    func createTextMessage(_ text: String)
    
    func viewDidDisappear()
    
    func configureMediaMessageImageView(withMessage message: Message, completion: @escaping (UIImage) -> ())
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
        
        setupBindings()
        
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
    
    func didTapAttachmentButton() {
        coordinator?.showAttachmentsActionSheet()
    }
    
    private func setupBindings() {
        NotificationCenter.default.publisher(for: .didAttachPhoto)
            .compactMap { $0.object as? UIImage }
            .sink { [weak self] image in
                self?.uploadMessagePhoto(image)
        }
        .store(in: &cancellables)
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
    
    func configureMediaMessageImageView(withMessage message: Message, completion: @escaping (UIImage) -> ()) {
        switch message.kind {
        case .photo(_):
            StorageManager.shared.downloadMessagePhoto(messageId: message.messageId)
                .receive(on: DispatchQueue.main)
                .sink { image in
                    completion(image)
            }
            .store(in: &cancellables)
        default:
            break
        }
    }
}

extension ChatViewModel {
    func createTextMessage(_ text: String) {
        guard let sender = sender else { return }
        
        let message = Message(messageId: generateMessageId(),
                              sentDate: Date(),
                              kind: .text(text),
                              user: sender)
        
        sendMessage(message)
    }
    
    private func uploadMessagePhoto(_ image: UIImage) {
        guard let imageData = image.pngData() else { return }
        
        let messageId = generateMessageId()
        
        StorageManager.shared.uploadMessagePhotoIntoStorage(imageData: imageData, messageId: messageId).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print(error)
            }
        }) { [weak self] urlString in
            self?.createPhotoMessage(urlString, messageId: messageId)
        }
        .store(in: &cancellables)
    }
    
    func createPhotoMessage(_ messagePhotoURL: String, messageId: String) {
        guard let sender = sender else { return }
        
        let media = Media(size: CGSize(width: 300, height: 300),
                          urlString: messagePhotoURL,
                          imageData: nil)
        let message = Message(messageId: messageId,
                              sentDate: Date(),
                              kind: .photo(media),
                              user: sender)
        sendMessage(message)
    }
    
    private func sendMessage(_ message: Message) {
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
