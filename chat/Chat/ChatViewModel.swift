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
import AVKit
import CoreLocation.CLLocation

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
    
    func didTapMessage(atIndexPath indexPath: IndexPath)
    func didTapImage(atIndexPath indexPath: IndexPath)
}

class ChatViewModel: ChatViewModelType {
    
    // MARK: - Properties
    var coordinator: ChatCoordinator?
    
    var title: String {
        return otherUser.displayName
    }
    
    let otherUser: AppUser
    
    var sender: AppUser? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentUser = appDelegate.currentUser else { return nil }
        
        return currentUser
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

// MARK: - Combine
extension ChatViewModel {
    private func setupBindings() {
        NotificationCenter.default.publisher(for: .didAttachPhoto)
            .compactMap { $0.object as? UIImage }
            .sink { [weak self] image in
                self?.uploadMessagePhoto(image)
        }
        .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .didAttachVideo)
            .compactMap { $0.object as? URL }
            .sink { [weak self] url in
                self?.uploadVideoMessage(videoURL: url)
        }
        .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .didAttachLocation)
            .compactMap { $0.object as? CLLocation }
            .sink { [weak self] location in
                self?.createLocationMessage(location)
        }
        .store(in: &cancellables)
    }
}

// MARK: - Handle MessageKit Delegate
extension ChatViewModel {
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
    
    func didTapMessage(atIndexPath indexPath: IndexPath) {
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .location(let location):
            coordinator?.showLocation(withLocation: location.location)
        default:
            break
        }
    }
    
    func didTapImage(atIndexPath indexPath: IndexPath) {
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .video(let media):
            guard let url = media.url else { return }
            coordinator?.showVideo(withURL: url)
        default:
            break
        }
    }
}

// MARK: - Message Manage

extension ChatViewModel {
    
    // Text Message
    func createTextMessage(_ text: String) {
        guard let sender = sender else { return }
        
        let message = Message(messageId: generateMessageId(),
                              sentDate: Date(),
                              kind: .text(text),
                              user: sender)
        
        sendMessage(message)
    }
    
    // Photo Message
    private func uploadMessagePhoto(_ image: UIImage) {
        guard let imageData = image.pngData() else { return }
        
        let messageId = generateMessageId()
        
        StorageManager.shared.uploadMessagePhotoIntoStorage(imageData: imageData, messageId: messageId)
            .sink(receiveCompletion: { completion in
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
    
    // Video Message
    func uploadVideoMessage(videoURL: URL) {
        let messageId = generateMessageId()
        
        StorageManager.shared.uploadMessageVideoIntoStorage(url: videoURL, messageId: messageId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }) { [weak self] urlString in
                self?.createVideoMessage(urlString, messageId: messageId)
        }
        .store(in: &cancellables)
    }
    
    func createVideoMessage(_ messageVideoURL: String, messageId: String) {
        guard let sender = sender else { return }
        
        let media = Media(size: CGSize(width: 300, height: 300),
                          urlString: messageVideoURL,
                          imageData: nil)
        
        let message = Message(messageId: messageId,
                              sentDate: Date(),
                              kind: .video(media),
                              user: sender)
        
        sendMessage(message)
    }
    
    // Location Message
    func createLocationMessage(_ location: CLLocation) {
        guard let sender = sender else { return }
        
        let locationMessage = Location(latitude: location.coordinate.latitude,
                                       longitude: location.coordinate.longitude,
                                       size: CGSize(width: 200, height: 100))
        
        let message = Message(messageId: generateMessageId(),
                              sentDate: Date(),
                              kind: .location(locationMessage),
                              user: sender)
        
        sendMessage(message)
    }
}

// MARK: - Message Hellpers
extension ChatViewModel {
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
