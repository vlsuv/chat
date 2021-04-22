//
//  AVPlayerCoordinator.swift
//  chat
//
//  Created by vlsuv on 20.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import AVKit
import Combine

class AVPLayerCoordinator: NSObject, Coordinator {
    
    // MARK: - Properties
    private(set) var childCoordinators: [Coordinator] = [Coordinator]()
    
    var parentCoordinator: Coordinator?
    
    private let navigationController: UINavigationController
    
    private let videoURL: URL
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(navigationController: UINavigationController, videoURL: URL) {
        self.navigationController = navigationController
        self.videoURL = videoURL
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Handlers
    func start() {
        let playerController = AVPlayerViewController()
        playerController.delegate = self
        
        let player = AVPlayer(url: videoURL)
        playerController.player = player
        
        NotificationCenter.default.publisher(for: .AVPLayerViewControllerDissmisingNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.parentCoordinator?.childDidFinish(self)
        }
        .store(in: &cancellables)
        
        navigationController.present(playerController, animated: true, completion: nil)
    }
}

// MARK: - AVPlayerViewControllerDelegate
extension AVPLayerCoordinator: AVPlayerViewControllerDelegate {
}
