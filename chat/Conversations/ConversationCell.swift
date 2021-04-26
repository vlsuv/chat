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
    
    var sendDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = Color.mediumGray
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = Color.black
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    var lastMessageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = Color.mediumGray
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    var statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    var cancellables = Set<AnyCancellable>()
    
    var viewModel: ConversationCellViewModelType? {
        willSet(viewModel) {
            guard let viewModel = viewModel else { return }
            
            userNameLabel.text = viewModel.name
            lastMessageLabel.text = viewModel.lastMessageContent
            sendDateLabel.text = viewModel.sendDate
            statusImageView.image = viewModel.isRead ? Image.read : Image.unread
            
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
        
        let userPhotoImageViewSize: CGFloat = 62
        userPhotoImageView.frame = CGRect(x: contentView.left + Spaces.leftSpace,
                                          y: (contentView.height - userPhotoImageViewSize) / 2,
                                          width: userPhotoImageViewSize,
                                          height: userPhotoImageViewSize)
        userPhotoImageView.layer.cornerRadius = userPhotoImageViewSize / 2
        
        let sendDateLabelWidth: CGFloat = 110
        sendDateLabel.frame = CGRect(x: contentView.width - sendDateLabelWidth - Spaces.rightSpace,
                                     y: userPhotoImageView.top,
                                     width: sendDateLabelWidth,
                                     height: contentView.height / 3)
        
        statusImageView.frame = CGRect(x: sendDateLabel.left - Spaces.horizontalSpaceBetweenElements - 19,
                                       y: userPhotoImageView.top,
                                       width: 19,
                                       height: contentView.height / 3)
        
        userNameLabel.frame = CGRect(x: userPhotoImageView.right + Spaces.horizontalSpaceBetweenElements,
                                     y: userPhotoImageView.top,
                                     width: contentView.width - userPhotoImageView.width - sendDateLabel.width - Spaces.leftSpace - Spaces.rightSpace - (Spaces.horizontalSpaceBetweenElements * 2) - statusImageView.width - Spaces.horizontalSpaceBetweenElements,
                                     height: contentView.height / 3)
        
        lastMessageLabel.frame = CGRect(x: userPhotoImageView.right + Spaces.horizontalSpaceBetweenElements,
                                        y: userNameLabel.bottom + Spaces.verticalSpaceBetweenElements,
                                        width: contentView.width - userPhotoImageView.width - sendDateLabel.width - Spaces.leftSpace - Spaces.rightSpace - (Spaces.horizontalSpaceBetweenElements * 2),
                                        height: userPhotoImageView.height - userNameLabel.height - Spaces.verticalSpaceBetweenElements)
        
        separatorInset.left = userPhotoImageView.width + Spaces.leftSpace + Spaces.horizontalSpaceBetweenElements
    }
    
    // MARK: - Handlers
    private func setupSubviews() {
        [userPhotoImageView, sendDateLabel, userNameLabel, lastMessageLabel, statusImageView].forEach{ contentView.addSubview($0) }
    }
}
