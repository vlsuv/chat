//
//  ChatCoordinator.swift
//  chat
//
//  Created by vlsuv on 09.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class ChatCoordinator: Coordinator {
    
    // MARK: - Properties
    private(set) var childCoordinators: [Coordinator] = [Coordinator]()
    
    private let navigationController: UINavigationController
    
    var parentCoordinator: Coordinator?
    
    let user: AppUser
    let conversation: Conversation?
    
    // MARK: - Init
    init(navigationController: UINavigationController, user: AppUser, conversation: Conversation?) {
        self.navigationController = navigationController
        self.user = user
        self.conversation = conversation
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Handlers
    func start() {
        let chatViewModel = ChatViewModel(otherUser: user, conversation: conversation)
        chatViewModel.coordinator = self
        
        let chatController = ChatController()
        chatController.viewModel = chatViewModel
        
        navigationController.pushViewController(chatController, animated: true)
    }
    
    func viewDidDisappear() {
        parentCoordinator?.childDidFinish(self)
    }
    
    func childDidFinish(_ childCoordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: { $0 === childCoordinator }) else { return }
        childCoordinators.remove(at: index)
    }
    
    func showAttachmentsActionSheet() {
        let attachmentsActionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let photoAction = UIAlertAction(title: "Photo", style: .default) { [weak self] action in
            attachmentsActionSheet.dismiss(animated: true, completion: nil)
            self?.showImagePicker()
        }
        
        attachmentsActionSheet.addAction(cancelAction)
        attachmentsActionSheet.addAction(photoAction)
        
        navigationController.present(attachmentsActionSheet, animated: true, completion: nil)
    }
    
    func showImagePicker() {
        let imagePickerCoordinator = ImagePickerCoordinator(navigationController: navigationController)
        imagePickerCoordinator.start()
        
        imagePickerCoordinator.parentCoordinator = self
        childCoordinators.append(imagePickerCoordinator)
        
        imagePickerCoordinator.didFinishPickingMedia = { info in
            guard let image = info[.editedImage] as? UIImage else { return }
            
            NotificationCenter.default.post(name: .didAttachPhoto, object: image)
        }
    }
}
