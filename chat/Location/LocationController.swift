//
//  LocationController.swift
//  chat
//
//  Created by vlsuv on 26.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine
import MapKit

class LocationController: UIViewController {
    
    // MARK: - Properties
    var viewModel: LocationViewModelType!
    
    var mapView: MKMapView = {
        let mapView = MKMapView()
        return mapView
    }()
    
    var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Image.placeholder
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var sendLocationButton: SendLocationButton = {
        let button = SendLocationButton()
        return button
    }()
    
    var userCurrentLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(Image.location, for: .normal)
        button.backgroundColor = Color.white
        return button
    }()
    
    var cancellables = Set<AnyCancellable>()
    
    private func configure() {
        configureNavigationController()
        setupMapView()
        setupUserCurrentLocationButton()
        
        setupBindings()
        
        if viewModel.isPickable {
            setupPlaceholderImageView()
            setupSendLocationButton()
        } else {
            setupSendedLocation()
        }
    }
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel?.title
        
        configure()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.viewDidDisappear()
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Targets
    @objc private func didTapCancelButton() {
        viewModel?.didTapCancel()
    }
    
    @objc private func didTapSendLocationButton() {
        viewModel?.didTapSendLocation()
    }
    
    @objc private func didTapUserLocationButton() {
        viewModel.didTapUserLocation()
    }
    
    // MARK: - Handlers
    private func configureNavigationController() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelButton))
        cancelButton.tintColor = Color.basicBlue
        
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    private func setupMapView() {
        mapView.frame = view.bounds
        mapView.delegate = self
        
        view.addSubview(mapView)
    }
    
    private func setupPlaceholderImageView() {
        let placeholderImageViewSize: CGFloat = 50
        placeholderImageView.frame = CGRect(x: mapView.center.x - (placeholderImageViewSize / 2),
                                            y: mapView.center.y - placeholderImageViewSize,
                                            width: placeholderImageViewSize,
                                            height: placeholderImageViewSize)
        
        view.addSubview(placeholderImageView)
    }
    
    private func setupSendLocationButton() {
        sendLocationButton.frame = CGRect(x: 0,
                                          y: view.bottom - 120,
                                          width: view.width,
                                          height: 60)
        
        sendLocationButton.addTarget(self, action: #selector(didTapSendLocationButton), for: .touchUpInside)
        
        view.addSubview(sendLocationButton)
    }
    
    private func setupUserCurrentLocationButton() {
        let currentLocationButtonSize: CGFloat = 40
        userCurrentLocationButton.frame = CGRect(x: view.right - currentLocationButtonSize - Spaces.rightSpace,
                                                 y: navigationController!.navigationBar.frame.size.height + Spaces.topSpace,
                                                 width: currentLocationButtonSize,
                                                 height: currentLocationButtonSize)
        userCurrentLocationButton.layer.cornerRadius = currentLocationButtonSize / 2
        
        userCurrentLocationButton.addTarget(self, action: #selector(didTapUserLocationButton), for: .touchUpInside)
        
        view.addSubview(userCurrentLocationButton)
    }
    
    private func setupSendedLocation() {
        guard let annotation = viewModel.annotation, let region = viewModel.region else { return }
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - Combine
extension LocationController {
    private func setupBindings() {
        viewModel.userLocation.sink { [weak self] location in
            self?.mapView.showsUserLocation = true
            self?.mapView.setRegion(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        }.store(in: &cancellables)
    }
}

// MARK: - MKMapViewDelegate
extension LocationController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        sendLocationButton.startLocating()
        
        let center = mapView.centerCoordinate
        
        viewModel?.regionDidChange(centerCordinate: center, completion: { [weak self] locationName in
            self?.sendLocationButton.setLocationName(locationName)
        })
    }
}
