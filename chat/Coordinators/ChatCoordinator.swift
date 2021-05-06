//
//  ChatCoordinator.swift
//  chat
//
//  Created by vlsuv on 09.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation

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
        let videoAction = UIAlertAction(title: "Video", style: .default) { [weak self] action in
            attachmentsActionSheet.dismiss(animated: true, completion: nil)
            self?.showVideoPicker()
        }
        let locationAction = UIAlertAction(title: "Location", style: .default) { [weak self] action in
            attachmentsActionSheet.dismiss(animated: true, completion: nil)
            self?.showLocation(withLocation: nil)
        }
        
        attachmentsActionSheet.addAction(cancelAction)
        attachmentsActionSheet.addAction(photoAction)
        attachmentsActionSheet.addAction(videoAction)
        attachmentsActionSheet.addAction(locationAction)
        
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
    
    func showVideoPicker() {
        let videoPickerCoordinator = VideoPickerCoordinator(navigationController: navigationController)
        videoPickerCoordinator.start()
        
        videoPickerCoordinator.parentCoordinator = self
        childCoordinators.append(videoPickerCoordinator)
        
        videoPickerCoordinator.didFinishPickingMedia = { info in
            guard let url = info[.mediaURL] as? URL else {
                return
            }
            
            NotificationCenter.default.post(name: .didAttachVideo, object: url)
        }
    }
    
    func showPlayer(withMediaURL url: URL) {
        let playerCoordinator = AVPLayerCoordinator(navigationController: navigationController, videoURL: url)
        playerCoordinator.start()
        
        playerCoordinator.parentCoordinator = self
        childCoordinators.append(playerCoordinator)
    }
    
    func showLocation(withLocation location: CLLocation?) {
        let locationCoordinator = LocationCoordinator(navigationController: navigationController, location: location)
        locationCoordinator.start()
        
        locationCoordinator.parentCoordinator = self
        childCoordinators.append(locationCoordinator)
    }
}
