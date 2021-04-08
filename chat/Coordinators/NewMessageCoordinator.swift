//
//  NewMessageCoordinator.swift
//  chat
//
//  Created by vlsuv on 08.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class NewMessageCoordinator: Coordinator {
    
    // MARK: - Properties
    private(set) var childCoordinators: [Coordinator] = [Coordinator]()
    
    var parentCoordinator: Coordinator?
    
    private let navigationController: UINavigationController
    private var modalNavigationController: UINavigationController?
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Handlers
    func start() {
        let newMessageViewModel = NewMessageViewModel()
        newMessageViewModel.coordinator = self
        
        let newMessageController = NewMessageController()
        newMessageController.viewModel = newMessageViewModel
        
        modalNavigationController = UINavigationController(rootViewController: newMessageController)
        
        if let modalNavigationController = modalNavigationController {
            navigationController.present(modalNavigationController, animated: true, completion: nil)
        }
    }
    
    func viewDidDisappear() {
        modalNavigationController?.viewControllers = []
        parentCoordinator?.childDidFinish(self)
    }
}
