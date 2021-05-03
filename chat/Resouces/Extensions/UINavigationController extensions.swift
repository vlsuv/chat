//
//  UINavigationController extensions.swift
//  chat
//
//  Created by vlsuv on 30.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

extension UINavigationController {
    func toTransparent() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = .clear
    }
}
