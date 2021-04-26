//
//  NewMessageController.swift
//  chat
//
//  Created by vlsuv on 08.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine

class NewMessageController: UIViewController {
    
    // MARK: - Properties
    private var tableView: UITableView!
    private var searchBar: UISearchBar!
    private var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = Color.black
        ai.hidesWhenStopped = true
        return ai
    }()
    
    var viewModel: NewMessageViewModelType!
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationController()
        configureTableView()
        setupSearchBar()
        setupBindings()
        setupSubviews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDisappear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicator.center = view.center
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Targets
    @objc private func didTapCancelButton() {
        viewModel.didTapCancel()
    }
    
    // MARK: - Handlers
    private func configureNavigationController() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(didTapCancelButton))
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    private func configureTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewMessageCell.self, forCellReuseIdentifier: NewMessageCell.identifier)
        
        tableView.rowHeight = 45
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
    }
    
    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.becomeFirstResponder()
        
        navigationItem.titleView = searchBar
    }
    
    private func setupBindings() {
        viewModel.resultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
        }
        .store(in: &cancellables)
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
        }
        .store(in: &cancellables)
    }
    
    private func setupSubviews() {
        [activityIndicator].forEach { view.addSubview($0) }
    }
}

// MARK: - UITableViewDataSource
extension NewMessageController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewMessageCell.identifier, for: indexPath) as? NewMessageCell, let newMessageCellViewModel = viewModel.newMessageCellViewModel(forIndexPath: indexPath) else { return UITableViewCell() }
        cell.viewModel = newMessageCellViewModel
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewMessageController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.didSelect(atIndexPath: indexPath)
    }
}

// MARK: - UISearchBarDelegate
extension NewMessageController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchUser(withText: searchText)
    }
}
