//
//  LocationViewModel.swift
//  chat
//
//  Created by vlsuv on 26.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine
import CoreLocation
import MapKit

protocol LocationViewModelType {
    var title: String { get }
    
    var isPickable: Bool { get set }
    
    var location: CLLocation? { get set }
    
    var userLocation: PassthroughSubject<CLLocationCoordinate2D, Never> { get }
    
    var annotation: MKAnnotation? { get }
    var region: MKCoordinateRegion? { get }
    
    func viewDidDisappear()
    func didTapCancel()
    
    func didTapSendLocation()
    
    func didTapUserLocation()
    
    func regionDidChange(centerCordinate: CLLocationCoordinate2D, completion: @escaping (String) -> ()) 
}

class LocationViewModel: NSObject, LocationViewModelType {
    
    // MARK: - Properties
    var title: String {
        return "Location"
    }
    
    weak var coordinator: LocationCoordinator?
    
    var isPickable = true
    var location: CLLocation?
    
    var userLocation = PassthroughSubject<CLLocationCoordinate2D, Never>()
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var annotation: MKAnnotation? {
        guard let location = location else { return nil }
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        return annotation
    }
    
    var region: MKCoordinateRegion? {
        guard let location = location else { return nil }
        let region = MKCoordinateRegion(center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        return region
    }

    // MARK: - Init
    convenience init(location: CLLocation) {
        self.init()
        self.location = location
        isPickable = false
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Handlers
    func viewDidDisappear() {
        coordinator?.viewDidDisappear()
    }
    
    func didTapCancel() {
        coordinator?.locationDidFinish()
    }
    
    func didTapSendLocation() {
        guard let location = location else { return }
        
        coordinator?.locationDidFinish()
        NotificationCenter.default.post(name: .didAttachLocation, object: location)
    }
    
    func didTapUserLocation() {
        checkLocationServices()
    }
}

// MARK: - Map Handlers
extension LocationViewModel {
    func regionDidChange(centerCordinate: CLLocationCoordinate2D, completion: @escaping (String) -> ()) {
        location = CLLocation(latitude: centerCordinate.latitude, longitude: centerCordinate.longitude)
        
        guard let location = location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemark, error in
            if error != nil {
                print(error!)
                return
            }
            
            guard let placemark = placemark?.first else { return }
            
            let cityName = placemark.locality ?? ""
            let streetName = placemark.thoroughfare ?? ""
            let houseNumber = placemark.subThoroughfare ?? ""
            
            let fullLocationName = "\(cityName) \(streetName) \(houseNumber)"
            
            if fullLocationName.replacingOccurrences(of: " ", with: "") == "" {
                completion("Unknown location")
            } else {
                completion(fullLocationName)
            }
        }
    }
}

// MARK: - Location Manager Handlers
extension LocationViewModel {
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            sendCenterUserLocation()
            locationManager.startUpdatingLocation()
            break
        @unknown default:
            break
        }
    }
    
    func sendCenterUserLocation() {
        guard let location = locationManager.location?.coordinate else { return }
        
        userLocation.send(location)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else { return }
        
        userLocation.send(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
