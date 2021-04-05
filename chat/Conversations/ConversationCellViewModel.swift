//
//  ConversationCellViewModel.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

protocol ConversationCellViewModelType {
    var name: String { get }
}

class ConversationCellViewModel: ConversationCellViewModelType {
    
    // MARK: - Properties
    let conversation: String
    
    var name: String {
        return conversation
    }
    
    // MARK: - Init
    init(conversation: String) {
        self.conversation = conversation
    }
}
