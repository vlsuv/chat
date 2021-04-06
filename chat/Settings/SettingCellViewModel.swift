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
    private let setting: String
    var name: String {
        return setting
    }
    
    // MARK: - Init
    init(setting: String) {
        self.setting = setting
    }
}
