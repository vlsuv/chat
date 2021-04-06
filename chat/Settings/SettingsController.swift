//
//  SettingsController.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {
    
    // MARK: - Properties
    private var tableView: UITableView!
    
    var viewModel: SettingsViewModelType!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    // MARK: - Handlers
    private func configureTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
        
        view.addSubview(tableView)
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
