//
//  NewMessageViewModel.swift
//  chat
//
//  Created by vlsuv on 08.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import Combine

protocol NewMessageViewModelType {
    func numberOfRows() -> Int
    func newMessageCellViewModel(forIndexPath indexPath: IndexPath) -> NewMessageCellViewModelType?
    
    var resultPublisher: Published<[AppUser]>.Publisher { get }
    
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    
    func viewDidDisappear()
    func didTapCancel()
    
    func searchUser(withText text: String)
    
    func didSelect(atIndexPath indexPath: IndexPath)
}

class NewMessageViewModel: NewMessageViewModelType {
    
    // MARK: - Properties
    var coordinator: NewMessageCoordinator?
    
    private var users: [AppUser] = [AppUser]()
    private var usersIsLoaded: Bool = false
    
    @Published private var result: [AppUser] = [AppUser]()
    var resultPublisher: Published<[AppUser]>.Publisher { $result }
    
    @Published var isLoading: Bool = false
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    deinit {
        print("deinit: \(self)")
    }
    
    // MARK: - Handlers
    func numberOfRows() -> Int {
        return result.count
    }
    
    func newMessageCellViewModel(forIndexPath indexPath: IndexPath) -> NewMessageCellViewModelType? {
        let user = result[indexPath.row]
        return NewMessageCellViewModel(user: user)
    }
    
    func viewDidDisappear() {
        coordinator?.viewDidDisappear()
    }
    
    func didTapCancel() {
        coordinator?.didCancelNewChat()
    }
}

extension NewMessageViewModel {
    
    func didSelect(atIndexPath indexPath: IndexPath) {
        let user = result[indexPath.row]
        coordinator?.showNewChat(withUser: user)
    }
    
    func searchUser(withText text: String) {
        isLoading = true
        
        let text = text.replacingOccurrences(of: " ", with: "").lowercased()
        
        if usersIsLoaded {
            filterUsers(withTerm: text)
        } else {
            getAllUsers(searchText: text)
        }
    }
    
    private func getAllUsers(searchText: String) {
        DatabaseManager.shared.fetchAllUsers()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }) { [weak self] users in
                self?.users = users
                self?.usersIsLoaded = true
                
                self?.filterUsers(withTerm: searchText)
        }
        .store(in: &cancellables)
    }
    
    private func filterUsers(withTerm term: String) {
        isLoading = false
        
        result = users.filter { $0.displayName.lowercased().hasPrefix(term) || $0.email.lowercased().hasPrefix(term) }
    }
}
