//
//  ChatController.swift
//  chat
//
//  Created by vlsuv on 09.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine
import MessageKit
import InputBarAccessoryView

class ChatController: MessagesViewController {
    
    // MARK: - Properties
    var viewModel: ChatViewModelType!
    
    var cancellables = Set<AnyCancellable>()
    
    var isReloaded: Bool = false
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        
        configureMessagesCollectionView()
        setupBindings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDisappear()
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    // MARK: - Handlers
    private func configureMessagesCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    private func setupBindings() {
        viewModel.messagesPublisher
            .sink { [weak self] _ in
                self?.messagesCollectionView.reloadData()
        }
        .store(in: &cancellables)
    }
}

// MARK: - MessagesDataSource
extension ChatController: MessagesDataSource {
    func currentSender() -> SenderType {
        return viewModel.currentSender()
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return viewModel.messageForItem(atIndexPath: indexPath)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return viewModel.numberOfSections()
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatController: MessagesLayoutDelegate {
    
}

// MARK: - MessagesDisplayDelegate
extension ChatController: MessagesDisplayDelegate {
    
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        viewModel.sendTextMessage(text)
        
        inputBar.inputTextView.text.removeAll()
    }
}
