//
//  ImagePickerCoordinator.swift
//  chat
//
//  Created by vlsuv on 06.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class ImagePickerCoordinator: NSObject, Coordinator {
    
    // MARK: - Properties
    private(set) var childCoordinators: [Coordinator] = [Coordinator]()
    
    var parentCoordinator: Coordinator?
    
    private let navigationController: UINavigationController
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("Deinit: \(self)")
    }
    
    // MARK: - Handlers
    func start() {
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            
            self.parentCoordinator?.childDidFinish(self)
        }
        let openGalleryAction = UIAlertAction(title: "Open Gallery", style: .default) { [weak self] _ in
            self?.showGallery()
        }
        let toTakePhotoAction = UIAlertAction(title: "To take a photo", style: .default) { _ in
        }
        
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(openGalleryAction)
        actionSheet.addAction(toTakePhotoAction)
        
        navigationController.present(actionSheet, animated: true, completion: nil)
    }
    
    private func showGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        
        navigationController.present(imagePicker, animated: true, completion: nil)
    }
    
    private func toTakePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        
        navigationController.present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ImagePickerCoordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        NotificationCenter.default.post(name: .didChangeUserPhoto, object: image)
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.parentCoordinator?.childDidFinish(self)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.parentCoordinator?.childDidFinish(self)
        }
    }
    
}
