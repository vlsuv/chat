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
}

class DatabaseManager {
    
    static let shared = DatabaseManager()
    private init() {}
    
    var ref = Database.database().reference()
    
}

extension DatabaseManager {
    
    func insertUserIntoDatabase(_ user: User) -> AnyPublisher<Void, DatabaseError> {
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
}
