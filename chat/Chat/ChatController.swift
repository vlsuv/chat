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
        setupMessageInputBar()
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
        messagesCollectionView.messageCellDelegate = self
    }
    
    private func setupMessageInputBar() {
        messageInputBar.delegate = self
        
        let attachmentButton = InputBarButtonItem()
        attachmentButton.onTouchUpInside { [weak self] _ in self?.viewModel.didTapAttachmentButton() }
        attachmentButton.setSize(CGSize(width: 35, height: 35), animated: false)
        attachmentButton.image = Image.paperclip
        
        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: false)
        messageInputBar.setStackViewItems([attachmentButton], forStack: .left, animated: false)
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
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else { return }
        
        viewModel.configureMediaMessageImageView(withMessage: message) { image in
            imageView.image = image
        }
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
        viewModel.createTextMessage(text)
        
        inputBar.inputTextView.text.removeAll()
    }
}

// MARK: - MessageCellDelegate
extension ChatController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        
        viewModel.didTapMessage(atIndexPath: indexPath)
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        
        viewModel.didTapImage(atIndexPath: indexPath)
    }
}
