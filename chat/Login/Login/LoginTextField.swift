//
//  LoginTextField.swift
//  chat
//
//  Created by vlsuv on 30.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class LoginTextField: UITextField {
    
    // MARK: - Properties
    private var fieldNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = Color.mediumGray
        return label
    }()
    
    private var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = Color.lightGray
        return view
    }()
    
    // MARK: - Init
    init(frame: CGRect, name: String) {
        super.init(frame: frame)
        fieldNameLabel.text = name
        
        configure()
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fieldNameLabel.frame = CGRect(x: 0,
                                      y: 0,
                                      width: self.width,
                                      height: 10)
        
        bottomLine.frame = CGRect(x: 0,
                                  y: self.height - 1,
                                  width: self.width,
                                  height: 1)
        
    }
    
    // MARK: - Handlers
    private func configure() {
//        self.leftView = UIView(frame: CGRect(x: 0,
//                                             y: 0,
//                                             width: 5,
//                                             height: 0))
//        self.leftViewMode = .always
    }
    
    private func addSubviews() {
        [fieldNameLabel, bottomLine]
            .forEach{ addSubview($0) }
    }
}
