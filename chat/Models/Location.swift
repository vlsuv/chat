//
//  Location.swift
//  chat
//
//  Created by vlsuv on 26.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Foundation
import MessageKit
import CoreLocation.CLLocation

struct Location: LocationItem, Codable {
    
    var latitude: Double
    var longitude: Double
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    var size: CGSize
}
