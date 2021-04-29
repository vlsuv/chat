//
//  LocationCoordinator.swift
//  chat
//
//  Created by vlsuv on 26.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation

class LocationCoordinator: Coordinator {
    
    // MARK: - Properties
    private(set) var childCoordinators: [Coordinator] = [Coordinator]()
    
    var parentCoordinator: Coordinator?
    
    private let navigationController: UINavigationController
    
    private var modalNavigationController: UINavigationController?
    
    var location: CLLocation?
    
    // MARK: - Init
    init(navigationController: UINavigationController, location: CLLocation?) {
        self.navigationController = navigationController
        self.location = location
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Handlers
    func start() {
        let locationViewModel: LocationViewModel
        
        if let location = location {
            locationViewModel = LocationViewModel(location: location)
        } else {
            locationViewModel = LocationViewModel()
        }
        locationViewModel.coordinator = self
        
        let locationController = LocationController()
        locationController.viewModel = locationViewModel
        
        modalNavigationController = UINavigationController()
        modalNavigationController?.viewControllers = [locationController]
        
        if let modalNavigationController = modalNavigationController {
            navigationController.present(modalNavigationController, animated: true, completion: nil)
        }
    }
    
    func viewDidDisappear() {
        parentCoordinator?.childDidFinish(self)
    }
    
    func locationDidFinish() {
        modalNavigationController?.dismiss(animated: true, completion: nil)
        
        parentCoordinator?.childDidFinish(self)
    }
    
    
}
