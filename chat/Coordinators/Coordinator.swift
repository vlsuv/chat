//
//  Coordinator.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    func start()
    
    var childCoordinators: [Coordinator] { get }
    func childDidFinish(_ childCoordinator: Coordinator)
    
}

extension Coordinator {
    func childDidFinish(_ childCoordinator: Coordinator) {}
}
