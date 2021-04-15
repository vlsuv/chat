//
//  ConversationCellViewModel.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine
import MessageKit

protocol ConversationCellViewModelType {
    var name: String { get }
    var userPhoto: CurrentValueSubject<UIImage, Never> { get set }
    var lastMessageContent: String { get }
}

class ConversationCellViewModel: ConversationCellViewModelType {
    
    // MARK: - Properties
    let conversation: Conversation
    
    var name: String { return conversation.otherUser.displayName }
    
    var userPhoto = CurrentValueSubject<UIImage, Never>(Image.defaultUserPicture)
    
    var lastMessageContent: String {
        
        var content: String = ""
        
        switch conversation.lastMessage.kind {
        case .text(let message):
            content = message
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        return content
    }
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(conversation: Conversation) {
        self.conversation = conversation
        
        getOtherUserPhoto(uid: conversation.otherUser.senderId)
    }
    
    // MARK: - Handlers
    private func getOtherUserPhoto(uid: String) {
        StorageManager.shared.downloadUserPhoto(userUid: uid)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }) { [weak self] image in
                self?.userPhoto.send(image)
        }
        .store(in: &cancellables)
    }
}
