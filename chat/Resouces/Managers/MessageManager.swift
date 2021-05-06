//
//  MessageManager.swift
//  chat
//
//  Created by vlsuv on 05.05.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine
import CoreLocation.CLLocation
import AVFoundation

protocol MessageManagerProtocol {
    var delegate: MessageManagerDelegate? { get set }
    
    func sendTextMessage(withText text: String)
    func sendPhotoMessage(withImage image: UIImage)
    func sendVideoMessage(fromLocalURL url: URL)
    func sendLocationMessage(withLocation location: CLLocation)
    func sendAudioMessage(fromLocalURL url: URL)
}

protocol MessageManagerDelegate: class {
    func didChangeMessageList(messages: [Message])
}

class MessageManager: MessageManagerProtocol {
    // MARK: - Properties
    weak var delegate: MessageManagerDelegate?
    
    var sender: AppUser? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentUser = appDelegate.currentUser else { return nil }
        
        return currentUser
    }
    
    private let otherUser: AppUser
    
    private var conversation: Conversation? {
        didSet {
            setupObserveForAllMessages()
        }
    }
    
    private var isNewChat: Bool {
        return conversation == nil
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(otherUser: AppUser, conversation: Conversation?) {
        self.otherUser = otherUser
        
        defer {
            self.conversation = conversation
        }
    }
    
    // MARK: - Text Message
    func sendTextMessage(withText text: String) {
        guard let sender = sender else { return }
        
        let message = Message(messageId: generateMessageId(),
                              sentDate: Date(),
                              kind: .text(text),
                              user: sender)
        
        sendMessage(message)
    }
    
    // MARK: - Photo Message
    func sendPhotoMessage(withImage image: UIImage) {
        guard let imageData = image.pngData(), sender != nil else { return }
        
        let photoMessageId = generateMessageId()
        
        StorageManager.shared.uploadMessagePhotoIntoStorage(imageData: imageData, messageId: photoMessageId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }) { [weak self] urlString in
                self?.createPhotoMessage(urlString, messageId: photoMessageId)
        }
        .store(in: &cancellables)
    }
    
    private func createPhotoMessage(_ messagePhotoURL: String, messageId: String) {
        let media = Media(size: CGSize(width: 300, height: 300),
                          urlString: messagePhotoURL,
                          imageData: nil)
        let message = Message(messageId: messageId,
                              sentDate: Date(),
                              kind: .photo(media),
                              user: sender!)
        sendMessage(message)
    }
    
    // MARK: - Video Message
    func sendVideoMessage(fromLocalURL url: URL) {
        guard sender != nil else { return }
        
        let messageId = generateMessageId()
        
        StorageManager.shared.uploadMessageVideoIntoStorage(url: url, messageId: messageId)
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
    
    private func createVideoMessage(_ messageVideoURL: String, messageId: String) {
        let media = Media(size: CGSize(width: 300, height: 300),
                          urlString: messageVideoURL,
                          imageData: nil)
        
        let message = Message(messageId: messageId,
                              sentDate: Date(),
                              kind: .video(media),
                              user: sender!)
        
        sendMessage(message)
    }
    
    // MARK: - Location Message
    func sendLocationMessage(withLocation location: CLLocation) {
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
    
    // MARK: - Audio Message
    func sendAudioMessage(fromLocalURL url: URL) {
        guard sender != nil else { return }
        
        let messageId = generateMessageId()
        
        StorageManager.shared.uploadMessageAudioIntoStorage(audioURL: url, messageId: messageId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }) { [weak self] url in
                self?.createAudioMessage(messageAudioURL: url, messageId: messageId)
        }
        .store(in: &cancellables)
    }
    
    private func createAudioMessage(messageAudioURL: URL, messageId: String) {
        let audioDuration = getAudioDuration(audioURL: messageAudioURL)
        
        let audio = Audio(url: messageAudioURL,
                          duration: audioDuration,
                          size: CGSize(width: 200, height: 100))
        
        let message = Message(messageId: messageId,
                              sentDate: Date(),
                              kind: .audio(audio),
                              user: sender!)
        
        sendMessage(message)
    }
    
    // MARK: - Send Message
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
}
// MARK: - Fetch Messages
extension MessageManager {
    private func setupObserveForAllMessages() {
        guard let conversationId = conversation?.id else { return }
        
        DatabaseManager.shared.observeForAllMesages(conversationId: conversationId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                self?.delegate?.didChangeMessageList(messages: messages)
        }
        .store(in: &cancellables)
    }
}

// MARK: - Helpers
extension MessageManager {
    private func generateMessageId() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .long
        dateFormatter.dateStyle = .medium
        return "\(sender!.senderId)_\(otherUser.senderId)_\(dateFormatter.string(from: Date()))"
    }
    
    private func getAudioDuration(audioURL: URL) -> Float {
        let audioAsset = AVURLAsset(url: audioURL)
        let duration = audioAsset.duration
        let durationInSeconds = CMTimeGetSeconds(duration)
        return Float(durationInSeconds)
    }
}
