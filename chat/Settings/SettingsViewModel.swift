//
//  SettingsViewModel.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Firebase
import Combine

struct Setting {
    var name: String
    var closure: (() -> ())?
}

protocol SettingsViewModelType {
    var userName: String { get }
    var userEmail: String { get }
    
    func numberOfRows() -> Int
    func settingCellViewModel(forIndexPath indexPath: IndexPath) -> SettingCellViewModelType?
    func didSelectRow(at indexPath: IndexPath)
    
    var userPhoto: CurrentValueSubject<UIImage, Never> { get set }
    
    func didTapChangeUserPhoto()
}

class SettingsViewModel: SettingsViewModelType {
    
    // MARK: - Properties
    var settings: [Setting] = [Setting]()
    
    weak var coordinator: SettingsCoordinator?
    
    private var cancellables = Set<AnyCancellable>()
    
    var userPhoto = CurrentValueSubject<UIImage, Never>(Image.defaultUserPicture)
    
    var appUser: AppUser? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentUser = appDelegate.currentUser else { return nil }
        
        return currentUser
    }
    
    var userName: String {
        return appUser?.displayName ?? ""
    }
    
    var userEmail: String {
        return appUser?.email ?? ""
    }
    
    // MARK: - Init
    init() {
        setupSettings()
        setupBindings()
        getUserPhoto()
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Handlers
    private func setupSettings() {
        let signOut = Setting(name: "Sign Out") { [weak self] in
            self?.coordinator?.showSignOutActionSheet(completion: {
                self?.handleSignOut()
            })
        }
        
        settings.append(signOut)
    }
    
    private func handleSignOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    func numberOfRows() -> Int {
        return settings.count
    }
    
    func settingCellViewModel(forIndexPath indexPath: IndexPath) -> SettingCellViewModelType? {
        let setting = settings[indexPath.row]
        return SettingCellViewModel(setting: setting)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        settings[indexPath.row].closure?()
    }
    
    func didTapChangeUserPhoto() {
        coordinator?.showImagePicker()
    }
    
    private func setupBindings() {
        NotificationCenter.default
            .publisher(for: .didChangeUserPhoto)
            .map{ $0.object as? UIImage }
            .sink { [weak self] image in
                self?.changeUserPhoto(atImage: image)
        }
        .store(in: &cancellables)
    }
}

extension SettingsViewModel {
    private func changeUserPhoto(atImage image: UIImage?) {
        guard let currentUser = Auth.auth().currentUser, let imageData = image?.pngData() else { return }
        
        StorageManager.shared
            .uploadUserPhotoIntoStorage(userUid: currentUser.uid, photoData: imageData)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }) { [weak self] _ in
                self?.getUserPhoto()
        }
        .store(in: &cancellables)
    }
    
    private func getUserPhoto() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        StorageManager.shared
            .downloadUserPhoto(userUid: currentUser.uid)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }) { [weak self] image in
                self?.userPhoto.send(image)
        }
        .store(in: &cancellables)
    }
}


