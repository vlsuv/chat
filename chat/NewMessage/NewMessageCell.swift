//
//  NewMessageCell.swift
//  chat
//
//  Created by vlsuv on 08.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine

class NewMessageCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "NewMessageCell"
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.black
        label.textAlignment = .left
        return label
    }()
    
    var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = Color.lightGray.cgColor
        return imageView
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    var viewModel: NewMessageCellViewModelType? {
        willSet(viewModel) {
            guard let viewModel = viewModel else { return }
            
            nameLabel.text = viewModel.name
            
            viewModel.photo
                .sink { [weak self] image in
                    self?.photoImageView.image = image
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
        
        let photoImageViewSize: CGFloat = 60
        photoImageView.frame = CGRect(x: contentView.left + 18,
                                      y: (contentView.height - photoImageViewSize) / 2,
                                      width: photoImageViewSize,
                                      height: photoImageViewSize)
        photoImageView.layer.cornerRadius = photoImageViewSize / 2
        
        nameLabel.frame = CGRect(x: photoImageView.right + 10,
                                 y: photoImageView.top,
                                 width: (contentView.width - photoImageViewSize) - 46,
                                 height: photoImageView.height)
        
    }
    
    // MARK: - Handlers
    private func setupSubviews() {
        [photoImageView, nameLabel].forEach { contentView.addSubview($0) }
    }
}
