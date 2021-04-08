//
//  NewMessageCellViewModel.swift
//  chat
//
//  Created by vlsuv on 08.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

protocol NewMessageCellViewModelType {
    var name: String { get }
}

class NewMessageCellViewModel: NewMessageCellViewModelType {
    
    // MARK: - Properties
    private let user: AppUser
    var name: String {
        return user.name
    }
    
    // MARK: - Init
    init(user: AppUser) {
        self.user = user
    }
}
