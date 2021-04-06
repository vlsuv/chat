//
//  User.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Foundation

struct User {
    var name: String
    var email: String
    var uid: String
}

extension User {
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "uid": uid
        ]
    }
}
