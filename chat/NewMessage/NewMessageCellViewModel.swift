//
//  NewMessageCellViewModel.swift
//  chat
//
//  Created by vlsuv on 08.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine

protocol NewMessageCellViewModelType {
    var name: String { get }
    var photo: CurrentValueSubject<UIImage, Never> { get set }
}

class NewMessageCellViewModel: NewMessageCellViewModelType {
    
    // MARK: - Properties
    private let user: AppUser
    var name: String {
        return user.displayName
    }
    var photo = CurrentValueSubject<UIImage, Never>(Image.defaultUserPicture)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(user: AppUser) {
        self.user = user
        getPhoto()
    }
    
    // MARK: - Handlers
    private func getPhoto() {
        StorageManager.shared.downloadUserPhoto(userUid: user.senderId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }) { [weak self] image in
                self?.photo.send(image)
        }
        .store(in: &cancellables)
    }
}
