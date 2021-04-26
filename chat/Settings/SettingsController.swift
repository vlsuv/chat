//
//  SettingsController.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine

class SettingsController: UIViewController {
    
    // MARK: - Properties
    private var tableView: UITableView!
    
    var viewModel: SettingsViewModelType!
    
    private var userPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = Color.lightGray.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .regular)
        label.textColor = Color.black
        label.textAlignment = .center
        return label
    }()
    
    private var userEmailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = Color.mediumGray
        label.textAlignment = .center
        return label
    }()
    
    private var changeUserPhotoButton: UIButton = {
        let button = UIButton()
        let normalAttributedString = NSAttributedString(string: "Set Photo", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular),
            NSAttributedString.Key.foregroundColor: Color.basicBlue
        ])
        button.setAttributedTitle(normalAttributedString, for: .normal)
        button.setImage(Image.camera.withTintColor(Color.basicBlue), for: .normal)
        button.titleEdgeInsets.left = Spaces.horizontalSpaceBetweenElements
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(didTapChangeUserPhotoButton), for: .touchUpInside)
        return button
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLabel.text = viewModel.userName
        userEmailLabel.text = viewModel.userEmail
        
        configureTableView()
        setupBindings()
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Targets
    @objc private func didTapChangeUserPhotoButton() {
        viewModel.didTapChangeUserPhoto()
    }
    
    // MARK: - Handlers
    private func configureTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
        
        tableView.tableHeaderView = createTableViewHeader()
        
        view.addSubview(tableView)
    }
    
    func createTableViewHeader() -> UIView {
        let userPhotoImageViewSize: CGFloat = 90
        let changeUserPhotoButtonHeight: CGFloat = 44
        let userNameLabelHeight: CGFloat = 25
        let userEmailLabelHeight: CGFloat = 15
        
        let tableViewHeader = UIView(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: view.width,
                                                   height: userPhotoImageViewSize + changeUserPhotoButtonHeight + userNameLabelHeight + userEmailLabelHeight + (Spaces.verticalSpaceBetweenElements * 4)))
        tableViewHeader.backgroundColor = Color.white
        
        userPhotoImageView.frame = CGRect(x: (tableViewHeader.width - userPhotoImageViewSize) / 2,
                                          y: tableViewHeader.top + Spaces.verticalSpaceBetweenElements,
                                          width: userPhotoImageViewSize,
                                          height: userPhotoImageViewSize)
        userPhotoImageView.layer.cornerRadius = userPhotoImageViewSize / 2
        
        userNameLabel.frame = CGRect(x: tableViewHeader.left + Spaces.leftSpace,
                                     y: userPhotoImageView.bottom + Spaces.verticalSpaceBetweenElements,
                                     width: tableViewHeader.width - (Spaces.leftSpace + Spaces.rightSpace),
                                     height: userNameLabelHeight)
        
        userEmailLabel.frame = CGRect(x: tableViewHeader.left + Spaces.leftSpace,
                                      y: userNameLabel.bottom + Spaces.verticalSpaceBetweenElements,
                                      width: tableViewHeader.width - (Spaces.leftSpace + Spaces.rightSpace),
                                      height: userEmailLabelHeight)
        
        changeUserPhotoButton.frame = CGRect(x: tableViewHeader.left + Spaces.leftSpace,
                                             y: userEmailLabel.bottom + Spaces.verticalSpaceBetweenElements,
                                             width: tableViewHeader.width - (Spaces.leftSpace + Spaces.rightSpace),
                                             height: changeUserPhotoButtonHeight)
        
        let separateLine = UIView(frame: CGRect(x: tableViewHeader.left,
                                                y: changeUserPhotoButton.top,
                                                width: tableViewHeader.width,
                                                height: 0.3))
        separateLine.backgroundColor = Color.lightGray
        
        [userPhotoImageView, userNameLabel, userEmailLabel, changeUserPhotoButton, separateLine]
            .forEach{ tableViewHeader.addSubview($0) }
        
        return tableViewHeader
    }
    
    private func setupBindings() {
        viewModel.userPhoto
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.userPhotoImageView.image = image
        }
        .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource
extension SettingsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier, for: indexPath) as? SettingCell,
            let settingCellViewModel = viewModel.settingCellViewModel(forIndexPath: indexPath) else {
                return UITableViewCell()
        }
        
        cell.viewModel = settingCellViewModel
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.didSelectRow(at: indexPath)
    }
}
