//
//  AVPlayerViewController extensions.swift
//  chat
//
//  Created by vlsuv on 22.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Foundation
import AVKit

extension AVPlayerViewController {
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isBeingDismissed == false {
            return
        }
        
        NotificationCenter.default.post(name: .AVPLayerViewControllerDissmisingNotification, object: nil)
    }
}
