//
//  ConversationsController.swift
//  chat
//
//  Created by vlsuv on 02.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit

class ConversationsController: UIViewController {
    
    // MARK: - Properties
    var tableView: UITableView!
    
    var viewModel: ConversationsViewModelType!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        
        configureNavigationController()
        configureTableView()
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Targets
    @objc private func didTapNewMessageButton() {
        print("handle new conversation")
    }
    
    // MARK: - Handlers
    private func configureNavigationController() {
        let newMessageButton = UIBarButtonItem(image: Image.newMessage, style: .plain, target: self, action: #selector(didTapNewMessageButton))
        
        navigationItem.rightBarButtonItem = newMessageButton
    }
    
    private func configureTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
        
        view.addSubview(tableView)
    }
}

// MARK: - UITableViewDataSource
extension ConversationsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.identifier, for: indexPath) as? ConversationCell,
            let conversationCellViewModel = viewModel.conversationCellViewModel(forIndexPath: indexPath) else {
                return UITableViewCell()
        }
        
        cell.viewModel = conversationCellViewModel
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ConversationsController: UITableViewDelegate {
    
}
