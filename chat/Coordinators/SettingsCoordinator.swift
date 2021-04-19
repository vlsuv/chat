//
//  SettingsCoordinator.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class SettingsCoordinator: Coordinator {
    
    // MARK: - Properties
    private(set) var childCoordinators: [Coordinator] = [Coordinator]()
    
    private let navigationController: UINavigationController
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    // MARK: - Handlers
    func start() {
        let settingsViewModel = SettingsViewModel()
        settingsViewModel.coordinator = self
        
        let settingsController = SettingsController()
        settingsController.viewModel = settingsViewModel
        
        navigationController.viewControllers = [settingsController]
    }
    
    func childDidFinish(_ childCoordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: { $0 === childCoordinator }) else { return }
        childCoordinators.remove(at: index)
    }
    
    func showImagePicker() {
        let imagePickerCoordinator = ImagePickerCoordinator(navigationController: navigationController)
        imagePickerCoordinator.parentCoordinator = self
        imagePickerCoordinator.start()
        childCoordinators.append(imagePickerCoordinator)
        
        imagePickerCoordinator.didFinishPickingMedia = { info in
            guard let image = info[.editedImage] as? UIImage else { return }
            
            NotificationCenter.default.post(name: .didChangeUserPhoto, object: image)
        }
    }
}
