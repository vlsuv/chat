//
//  SettingCellViewModel.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

protocol SettingCellViewModelType {
    var name: String { get }
}

class SettingCellViewModel: SettingCellViewModelType {
    
    // MARK: - Properties
    private let setting: Setting
    var name: String {
        return setting.name
    }
    
    // MARK: - Init
    init(setting: Setting) {
        self.setting = setting
    }
}
