//
//  User.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Foundation

struct AppUser: Decodable {
    var name: String
    var email: String
    var uid: String
}

extension AppUser {
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "uid": uid
        ]
    }
}
