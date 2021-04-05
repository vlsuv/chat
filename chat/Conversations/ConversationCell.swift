//
//  ConversationCell.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "ConversationCell"
    
    var viewModel: ConversationCellViewModelType? {
        willSet(viewModel) {
            guard let viewModel = viewModel else { return }
            
            textLabel?.text = viewModel.name
        }
    }
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
