//
//  SettingsViewModel.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Firebase

protocol SettingsViewModelType {
    func numberOfRows() -> Int
    func settingCellViewModel(forIndexPath indexPath: IndexPath) -> SettingCellViewModelType?
    func didSelectRow(at indexPath: IndexPath)
}

class SettingsViewModel: SettingsViewModelType {
    
    // MARK: - Properties
    var settings: [String] = ["Sign out"]
    
    var coordinator: SettingsCoordinator?
    
    // MARK: - Handlers
    func numberOfRows() -> Int {
        return settings.count
    }
    
    func settingCellViewModel(forIndexPath indexPath: IndexPath) -> SettingCellViewModelType? {
        let setting = settings[indexPath.row]
        return SettingCellViewModel(setting: setting)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        do {
            try Auth.auth().signOut()
            coordinator?.showLogin()
        } catch {
            print(error)
        }
    }
}
