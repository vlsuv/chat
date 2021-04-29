//
//  SendLocationButton.swift
//  chat
//
//  Created by vlsuv on 28.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class SendLocationButton: UIButton{
    
    // MARK: - Properties
    var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = Image.placeholder
        return imageView
    }()
    
    var actionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = Color.black
        label.text = "Send This Location:"
        return label
    }()
    
    var locationNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = Color.mediumGray
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Color.white
        layer.borderWidth = 1
        layer.borderColor = Color.lightGray.cgColor
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconImageViewSize: CGFloat = 30
        iconImageView.frame = CGRect(x: Spaces.leftSpace,
                                     y: (height - iconImageViewSize) / 2,
                                     width: iconImageViewSize,
                                     height: iconImageViewSize)
        
        actionLabel.frame = CGRect(x: iconImageView.right + Spaces.horizontalSpaceBetweenElements,
                                   y: iconImageView.top,
                                   width: width - (iconImageView.width + Spaces.horizontalSpaceBetweenElements) - (Spaces.leftSpace + Spaces.rightSpace),
                                   height: iconImageView.height / 2)
        
        locationNameLabel.frame = CGRect(x: iconImageView.right + Spaces.horizontalSpaceBetweenElements,
                                         y: actionLabel.bottom,
                                         width: width - (iconImageView.width + Spaces.horizontalSpaceBetweenElements) - (Spaces.leftSpace + Spaces.rightSpace),
                                         height: iconImageView.height / 2)
    }
    
    // MARK: - Handlers
    private func addSubviews() {
        [iconImageView, actionLabel, locationNameLabel]
            .forEach { addSubview($0) }
    }
    
    func startLocating() {
        locationNameLabel.text = "Locating..."
    }
    
    func setLocationName(_ locationName: String) {
        locationNameLabel.text = locationName
    }
}
