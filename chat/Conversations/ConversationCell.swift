//
//  ConversationCell.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine

class ConversationCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "ConversationCell"
    
    var userPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = Color.lightGray.cgColor
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.black
        label.textAlignment = .left
        return label
    }()
    
    var lastMessageLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.lightGray
        label.textAlignment = .left
        return label
    }()
    
    var cancellables = Set<AnyCancellable>()
    
    var viewModel: ConversationCellViewModelType? {
        willSet(viewModel) {
            guard let viewModel = viewModel else { return }
            
            userNameLabel.text = viewModel.name
            lastMessageLabel.text = viewModel.lastMessageContent
            
            viewModel.userPhoto
                .sink { [weak self] image in
                    self?.userPhotoImageView.image = image
            }
            .store(in: &cancellables)
        }
    }
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let userPhotoImageViewSize: CGFloat = 70
        userPhotoImageView.frame = CGRect(x: contentView.left + 18,
                                          y: (contentView.height - userPhotoImageViewSize) / 2,
                                          width: userPhotoImageViewSize,
                                          height: userPhotoImageViewSize)
        userPhotoImageView.layer.cornerRadius = userPhotoImageViewSize / 2
        
        userNameLabel.frame = CGRect(x: userPhotoImageView.right + 10,
                                     y: userPhotoImageView.top,
                                     width: contentView.width - userPhotoImageView.width - 20,
                                     height: userPhotoImageView.height / 4)
        
        lastMessageLabel.frame = CGRect(x: userPhotoImageView.right + 10,
                                        y: userNameLabel.bottom + 10,
                                        width: contentView.width - userPhotoImageView.width - 20,
                                        height: userPhotoImageView.height - userNameLabel.height - 10)
    }
    
    // MARK: - Handlers
    private func setupSubviews() {
        [userPhotoImageView, userNameLabel, lastMessageLabel].forEach{ contentView.addSubview($0) }
    }
}
