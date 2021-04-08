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
    
    private var userPhotoImageView: UIImageView!
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let tableViewHeader = UIView(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: view.width,
                                                   height: 210))
        tableViewHeader.backgroundColor = Color.white
        
        let userPhotoImageViewSize: CGFloat = 110
        let changeUserPhotoButtonHeight: CGFloat = 52
        
        userPhotoImageView = UIImageView(frame: CGRect(x: (tableViewHeader.width - userPhotoImageViewSize) / 2,
                                                             y: (tableViewHeader.height - userPhotoImageViewSize - changeUserPhotoButtonHeight - 10) / 2,
                                                             width: userPhotoImageViewSize,
                                                             height: userPhotoImageViewSize))
        userPhotoImageView.layer.cornerRadius = userPhotoImageViewSize / 2
        userPhotoImageView.layer.borderWidth = 2
        userPhotoImageView.layer.borderColor = Color.lightGray.cgColor
        userPhotoImageView.contentMode = .scaleAspectFill
        userPhotoImageView.clipsToBounds = true
        
        let changeUserPhotoButton = UIButton(frame: CGRect(x: tableViewHeader.left + 18,
                                                         y: userPhotoImageView.bottom + 10,
                                                         width: tableViewHeader.width - 36,
                                                         height: changeUserPhotoButtonHeight))
        changeUserPhotoButton.setTitle("Change photo", for: .normal)
        changeUserPhotoButton.setTitleColor(Color.blue, for: .normal)
        changeUserPhotoButton.contentHorizontalAlignment = .left
        changeUserPhotoButton.addTarget(self, action: #selector(didTapChangeUserPhotoButton), for: .touchUpInside)
        
        tableViewHeader.addSubview(userPhotoImageView)
        tableViewHeader.addSubview(changeUserPhotoButton)
        
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
        viewModel.didSelectRow(at: indexPath)
    }
}
