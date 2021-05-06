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
import CoreLocation.CLLocation

protocol ChatViewModelType {
    func viewDidDisappear()
    
    var title: String { get }
    
    func currentSender() -> SenderType
    func messageForItem(atIndexPath indexPath: IndexPath) -> MessageType
    func numberOfSections() -> Int
    
    func didTapAudioRecordingButton()
    func didTapAttachmentButton()
    
    func didTapMessage(atIndexPath indexPath: IndexPath)
    func didTapImage(atIndexPath indexPath: IndexPath)
    func didTapPlay(message: MessageType, cell: AudioMessageCell)
    
    func createTextMessage(_ text: String)
    
    func configureMediaMessageImageView(withMessage message: Message, completion: @escaping (UIImage) -> ())
    
    var messagesPublisher: Published<[Message]>.Publisher { get }
    var recordingButtonIsShowPublisher: Published<Bool>.Publisher { get }
    var isRecordingPublisher: Published<Bool>.Publisher { get }
}

class ChatViewModel: NSObject, ChatViewModelType {
    
    // MARK: - Properties
    var coordinator: ChatCoordinator?
    
    private var audioRecordingManager: AudioRecordingManagerProtocol?
    private var messageManager: MessageManagerProtocol?
    
    var cancellables = Set<AnyCancellable>()
    
    var title: String {
        return otherUser.displayName
    }
    let otherUser: AppUser
    
    var sender: AppUser? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentUser = appDelegate.currentUser else { return nil }
        
        return currentUser
    }
    
    @Published var messages: [Message] = [Message]()
    var messagesPublisher: Published<[Message]>.Publisher { $messages }
    
    @Published var isRecording: Bool = false
    var isRecordingPublisher: Published<Bool>.Publisher { $isRecording }
    
    @Published var recordingButtonIsShow: Bool = false
    var recordingButtonIsShowPublisher: Published<Bool>.Publisher { $recordingButtonIsShow }
    
    // MARK: - Init
    init(otherUser: AppUser, conversation: Conversation?) {
        self.otherUser = otherUser
        
        super.init()
        
        setupBindings()
        setupMessageManager(otherUser: otherUser, conversation: conversation)
        setupAudioRecordingManager()
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
    
    func didTapAudioRecordingButton() {
        audioRecordingManager?.didTapRecordingButton()
    }
    
    func didTapPlay(message: MessageType, cell: AudioMessageCell) {
        switch message.kind {
        case .audio(let item):
            coordinator?.showPlayer(withMediaURL: item.url)
        default:
            break
        }
    }
    
    private func setupMessageManager(otherUser: AppUser, conversation: Conversation?) {
        messageManager = MessageManager(otherUser: otherUser, conversation: conversation)
        messageManager?.delegate = self
    }
    
    private func setupAudioRecordingManager() {
        audioRecordingManager = AudioRecordingManager()
        audioRecordingManager?.delegate = self
        
        audioRecordingManager?.setupRecordingSession()
    }
    
    func createTextMessage(_ text: String) {
        messageManager?.sendTextMessage(withText: text)
    }
}

// MARK: - Combine Handlers
extension ChatViewModel {
    private func setupBindings() {
        NotificationCenter.default.publisher(for: .didAttachPhoto)
            .compactMap { $0.object as? UIImage }
            .sink { [weak self] image in
                self?.messageManager?.sendPhotoMessage(withImage: image)
        }
        .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .didAttachVideo)
            .compactMap { $0.object as? URL }
            .sink { [weak self] url in
                self?.messageManager?.sendVideoMessage(fromLocalURL: url)
        }
        .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .didAttachLocation)
            .compactMap { $0.object as? CLLocation }
            .sink { [weak self] location in
                self?.messageManager?.sendLocationMessage(withLocation: location)
        }
        .store(in: &cancellables)
    }
}

// MARK: - MessageKit Handlers
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
            coordinator?.showPlayer(withMediaURL: url)
        default:
            break
        }
    }
}

// MARK: - MessageManagerDelegate
extension ChatViewModel: MessageManagerDelegate {
    func didChangeMessageList(messages: [Message]) {
        self.messages = messages
    }
}

// MARK: - AudioRecordingManagerDelegate
extension ChatViewModel: AudioRecordingManagerDelegate {
    func didChangeRecordingState(to state: AudioRecordingState) {
        switch state {
        case .playing:
            isRecording = true
        case .stopped:
            isRecording = false
        }
    }
    
    func didSetupRecordingSession(succes: Bool) {
        if succes {
            recordingButtonIsShow = true
        }
    }
    
    func audioRecorderDidFinishRecording(audioURL: URL) {
        messageManager?.sendAudioMessage(fromLocalURL: audioURL)
    }
}
