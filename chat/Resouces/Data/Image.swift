//
//  Image.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

enum Image {
    static let defaultUserPicture = UIImage(systemName: "person.circle.fill") ?? UIImage()
    
    static let chats = UIImage(named: "bubble.left.and.bubble.right") ?? UIImage()
    static let chatsFill = UIImage(named: "bubble.left.and.bubble.right.fill") ?? UIImage()
    
    static let newMessage = UIImage(named: "square.and.pencil") ?? UIImage()
    
    static let settings = UIImage(named: "gear") ?? UIImage()
    
    static let read = UIImage(named: "send.read") ?? UIImage()
    static let unread = UIImage(named: "send.unread") ?? UIImage()
    
    static let trash = UIImage(systemName: "trash") ?? UIImage()
    
    static let camera = UIImage(systemName: "camera") ?? UIImage()
    
    static let paperclip = UIImage(systemName: "paperclip") ?? UIImage()
}
