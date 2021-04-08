//
//  DatabaseManager.swift
//  chat
//
//  Created by vlsuv on 05.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Foundation
import Combine
import FirebaseDatabase

enum DatabaseError: Error {
    case FailedToAddUser
    case FailedToFetchUsers
}

class DatabaseManager {
    
    static let shared = DatabaseManager()
    private init() {}
    
    var ref = Database.database().reference()
    
}

extension DatabaseManager {
    
    func insertUserIntoDatabase(_ user: AppUser) -> AnyPublisher<Void, DatabaseError> {
        return Future { [weak self] promise in
            
            let userDictionary = user.toDictionary()
            
            self?.ref.child(user.uid).setValue(userDictionary, withCompletionBlock: { error, _ in
                if error != nil {
                    promise(.failure(.FailedToAddUser))
                    return
                }
            })
            
            self?.ref.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var userCollection = snapshot.value as? [[String: Any]] {
                    userCollection.append(userDictionary)
                    self?.ref
                        .child("users")
                        .setValue(userCollection, withCompletionBlock: { error, _ in
                            if error != nil {
                                promise(.failure(.FailedToAddUser))
                                return
                            }
                            promise(.success(()))
                        })
                } else {
                    let newUserCollection: [[String: Any]] = [
                        userDictionary
                    ]
                    self?.ref
                        .child("users")
                        .setValue(newUserCollection, withCompletionBlock: { error, _ in
                            if error != nil {
                                promise(.failure(.FailedToAddUser))
                                return
                            }
                            promise(.success(()))
                        })
                }
            })
        }.eraseToAnyPublisher()
    }
    
    func existUser(withUid uid: String) -> AnyPublisher<Bool, Never> {
        return Future { [weak self] promise in
            self?.ref.child(uid).observeSingleEvent(of: .value, with: { snapshot in
                promise(.success(snapshot.exists()))
            })
        }.eraseToAnyPublisher()
    }
    
    func fetchAllUsers() -> AnyPublisher<[AppUser], DatabaseError> {
        return Future { [weak self] promise in
            self?.ref.child("users").observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value,
                    let jsonData = try? JSONSerialization.data(withJSONObject: value),
                    let users = try? JSONDecoder().decode([AppUser].self, from: jsonData) else {
                        promise(.failure(.FailedToFetchUsers))
                        return
                }
                promise(.success(users))
            })
        }.eraseToAnyPublisher()
    }
}
