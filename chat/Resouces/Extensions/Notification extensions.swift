//
//  Notification extensions.swift
//  chat
//
//  Created by vlsuv on 22.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let didChangeUserPhoto = Notification.Name("didChangeUserPhoto")
    static let didAttachPhoto = Notification.Name("didAttachPhoto")
    static let didAttachVideo = Notification.Name("didAttachVideo")
    static let AVPLayerViewControllerDissmisingNotification = Notification.Name("AVPLayerViewControllerDissmisingNotification")
}
