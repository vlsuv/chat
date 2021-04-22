//
//  Media.swift
//  chat
//
//  Created by vlsuv on 16.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Foundation
import MessageKit

struct Media: MediaItem, Codable {
    var url: URL? {
        guard let urlString = urlString else { return nil }
        return URL(string: urlString)
    }
    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    var placeholderImage: UIImage {
        return UIImage()
    }
    var size: CGSize
    
    var urlString: String?
    var imageData: Data?
}
