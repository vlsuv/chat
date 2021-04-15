//
//  Conversation.swift
//  chat
//
//  Created by vlsuv on 09.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Foundation
import MessageKit

struct Conversation: Codable {
    var id: String
    var otherUser: AppUser
    var lastMessage: Message
}
