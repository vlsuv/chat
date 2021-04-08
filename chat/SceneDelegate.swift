//
//  SceneDelegate.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private var appCoordinator: AppCoordinator?
    private var authState: Cancellable?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.windowScene = windowScene
        if let window = window {
            appCoordinator = AppCoordinator(window: window)
            appCoordinator?.start()
            setupAuthStateSubscriber()
        }
    }
}

extension SceneDelegate {
    func setupAuthStateSubscriber() {
        authState = Publishers.AuthPublisher()
            .map { $0 != nil }
            .sink { [weak self] isLogged in
                isLogged ? self?.appCoordinator?.startApp() : self?.appCoordinator?.showLogin()
        }
    }
}

