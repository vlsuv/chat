//
//  Message.swift
//  chat
//
//  Created by vlsuv on 09.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Foundation
import MessageKit

struct Message: MessageType, Codable {
    var sender: SenderType {
        return user
    }
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    var user: AppUser
}

extension MessageKind: Codable {
    enum Key: CodingKey {
        case text
        case attributedText
        case photo
        case video
        case location
        case emoji
        case audio
        case contact
        case linkPreview
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let key = container.allKeys.first
        
        switch key {
        case .text:
            let message = try container.decode(String.self, forKey: .text)
            self = .text(message)
        case .photo:
            let media = try container.decode(Media.self, forKey: .photo)
            self = .photo(media)
        case .none:
            throw CodingError.unknownValue
        case .some(_):
            throw CodingError.unknownValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        
        switch self {
        case .text(let message):
            try container.encode(message, forKey: .text)
        case .attributedText(_):
            break
        case .photo(let media):
            guard let media = media as? Media else { return }
            try container.encode(media, forKey: .photo)
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
    }
}
