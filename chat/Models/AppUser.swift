//
//  User.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Foundation
import MessageKit

struct AppUser: SenderType, Codable {
    var senderId: String
    var displayName: String
    var email: String
}
