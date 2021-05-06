//
//  Audio.swift
//  chat
//
//  Created by vlsuv on 03.05.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import MessageKit

struct Audio: AudioItem, Codable {
    var url: URL
    var duration: Float
    var size: CGSize
}
