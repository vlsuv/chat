//
//  AppCoordinator.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    
    // MARK: - Properties
    private(set) var childCoordinators: [Coordinator] = [Coordinator]()
    
    private let window: UIWindow
    
    private var tabBarController: UITabBarController?
    
    // MARK: - Init
    init(window: UIWindow) {
        self.window = window
    }
    
    // MARK: - Handlers
    func start() {
        tabBarController = UITabBarController()
        tabBarController?.view.backgroundColor = Color.white
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    func childDidFinish(_ childCoordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: { $0 === childCoordinator }) else { return }
        childCoordinators.remove(at: index)
    }
    
    func startApp() {
        let conversationsNavigationController = createNavigationController(title: "Conversations", image: Image.conversations)
        let conversationsCoordinator = ConversationsCoordinator(navigationController: conversationsNavigationController)
        conversationsCoordinator.start()
        childCoordinators.append(conversationsCoordinator)
        
        let settingsNavigationController = createNavigationController(title: "Settings", image: Image.settings)
        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNavigationController)
        settingsCoordinator.start()
        childCoordinators.append(settingsCoordinator)
        
        tabBarController?.viewControllers = [conversationsNavigationController, settingsNavigationController]
    }
    
    func showLogin() {
        guard let tabBarController = tabBarController else { return }
        
        childCoordinators.removeAll()
        tabBarController.viewControllers?.removeAll()
        
        let loginCoordinator = LoginCoordinator(tabBarController: tabBarController)
        loginCoordinator.parentCoordinator = self
        loginCoordinator.start()
        childCoordinators.append(loginCoordinator)
    }
}

extension AppCoordinator {
    private func createNavigationController(title: String, image: UIImage?) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: image)
        return navigationController
    }
}
