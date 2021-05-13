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

enum DatabaseEndpoint {
    case user(id: String)
    case users
    
    case messages(conversationId: String)
    
    case conversations(user: AppUser)
    
    var baseRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var ref: DatabaseReference {
        switch self {
        case .user(id: let id):
            return baseRef.child(id)
        case .users:
            return baseRef.child("users")
        case .messages(conversationId: let conversationId):
            return baseRef.child("\(conversationId)/messages")
        case .conversations(user: let user):
            return baseRef.child("\(user.senderId)/conversations")
        }
    }
}

class DatabaseManager {
    
    private let databaseService: DatabaseServiceProtocol = DatabaseService()
    
    static let shared = DatabaseManager()
    
    private init() {}
}

// MARK: - User
extension DatabaseManager {
    func insertUserIntoDatabase(_ user: AppUser) -> AnyPublisher<Void, Error> {
        
        let userRef = DatabaseEndpoint.user(id: user.senderId).ref
        let usersRef = DatabaseEndpoint.users.ref
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.databaseService.insertObjectIntoDatabase(reference: userRef, object: user) { error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                self.getId(collectionReference: usersRef) { id in
                    self.databaseService.insertObjectIntoDatabase(reference: usersRef.child("\(id)"), object: user) { error in
                        if let error = error {
                            promise(.failure(error))
                            return
                        }
                    }
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchAllUsers() -> AnyPublisher<[AppUser], DatabaseServiceError> {
        let usersRef = DatabaseEndpoint.users.ref
        return databaseService.fetchObject(reference: usersRef, decodingType: [AppUser].self, eventType: .value)
    }
}

// MARK: - Conversation
extension DatabaseManager {
    func createConversation(otherUser: AppUser, message: Message) -> AnyPublisher<Conversation, Error> {
        
        let conversationId: String = generateConversationId(withMessage: message)
        let messagesRef = DatabaseEndpoint.messages(conversationId: conversationId).ref
        let newMessageRef = messagesRef.child("\(0)")
        
        return Future { [weak self] promise in
            
            let users: [AppUser] = [otherUser, message.user]
            
            for (index, user) in users.enumerated() {
                self?.addConversationIntoUserCollection(user: user,
                                                        conversation: Conversation(id: conversationId,
                                                                                   otherUser: users[(index + 1) % users.count],
                                                                                   lastMessage: message))
            }
            
            self?.databaseService.insertObjectIntoDatabase(reference: newMessageRef, object: message, completion: { error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                let conversation = Conversation(id: conversationId, otherUser: otherUser, lastMessage: message)
                promise(.success(conversation))
            })
        }
        .eraseToAnyPublisher()
    }
    
    func addConversationIntoUserCollection(user: AppUser, conversation: Conversation) {
        let conversationsRef = DatabaseEndpoint.conversations(user: user).ref
        
        existConversationIntoSenderCollection(sender: user, conversation: conversation) { [weak self] isExist in
            guard let self = self else { return }
            
            if !isExist {
                self.getId(collectionReference: conversationsRef) { id in
                    self.databaseService.insertObjectIntoDatabase(reference: conversationsRef.child("\(id)"), object: conversation) { error in
                        if let error = error {
                            print(error)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func deleteConversation(_ conversation: Conversation, user: AppUser) -> AnyPublisher<Void, Error> {
        let conversationsRef = DatabaseEndpoint.conversations(user: user).ref
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.databaseService.fetchObject(reference: conversationsRef, decodingType: [Conversation].self, eventType: .value) { result in
                switch result {
                case .success(let conversations):
                    guard let index = conversations.firstIndex(where: { $0.id == conversation.id }) else { return }
                    
                    conversationsRef.child("\(index)").removeValue { error, _ in
                        if let error = error {
                            promise(.failure(error))
                            return
                        }
                        promise(.success(()))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func observeForAllConversations(user: AppUser) -> AnyPublisher<[Conversation], Error> {
        let conversationsRef = DatabaseEndpoint.conversations(user: user).ref
        return databaseService.observeObject(reference: conversationsRef, decodingType: [Conversation].self)
    }
}

// MARK: Message
extension DatabaseManager {
    func sendMessage(to conversation: Conversation, message: Message) -> AnyPublisher<Void, Error> {
        let messagesRef = DatabaseEndpoint.messages(conversationId: conversation.id).ref
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.getId(collectionReference: messagesRef) { id in
                self.databaseService.insertObjectIntoDatabase(reference: messagesRef.child("\(id)"), object: message) { error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    let users: [AppUser] = [message.user, conversation.otherUser]
                    for user in users {
                        self.sendMessageIntoUserCollection(user: user, conversation: conversation, message: message)
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func sendMessageIntoUserCollection(user: AppUser, conversation: Conversation, message: Message ) {
        
        let conversationsRef = DatabaseEndpoint.conversations(user: user).ref
        
        databaseService.fetchObject(reference: conversationsRef, decodingType: [Conversation].self, eventType: .value) { [weak self] result in
            switch result {
            case .success(let conversations):
                guard let index = conversations.firstIndex(where: { $0.id == conversation.id }) else { return }
                
                let conversationRef = conversationsRef.child("\(index)/lastMessage")
                
                self?.databaseService.insertObjectIntoDatabase(reference: conversationRef, object: message, completion: { error in
                    if let error = error {
                        print(error)
                        return
                    }
                })
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func observeForAllMesages(conversationId: String) -> AnyPublisher<[Message], Error> {
        let messagesRef = DatabaseEndpoint.messages(conversationId: conversationId).ref
        return databaseService.observeObject(reference: messagesRef, decodingType: [Message].self)
    }
}

extension DatabaseManager {
    func existConversationIntoOtherUserCollection(sender: AppUser, otherUser: AppUser, completion: @escaping (Conversation?) -> ()) {
        let conversationsRef = DatabaseEndpoint.conversations(user: otherUser).ref
        
        databaseService.fetchObject(reference: conversationsRef, decodingType: [Conversation].self, eventType: .value) { result in
            switch result {
            case .success(let conversations):
                if let index = conversations.firstIndex(where: { $0.otherUser.senderId == sender.senderId }) {
                    var conversation = conversations[index]
                    conversation.otherUser = otherUser
                    completion(conversation)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func existConversationIntoSenderCollection(sender: AppUser, conversation: Conversation, completion: @escaping (Bool) -> ()) {
        let conversationsRef = DatabaseEndpoint.conversations(user: sender).ref
        
        databaseService.fetchObject(reference: conversationsRef, decodingType: [Conversation].self, eventType: .value) { results in
            switch results {
            case .success(let conversations):
                if conversations.contains(where: { $0.id == conversation.id }) {
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(_):
                completion(false)
            }
        }
    }
    
    private func getId(collectionReference: DatabaseReference, completion: @escaping (Int) -> ()) {
        collectionReference.observeSingleEvent(of: .value) { snapshot in
            if let collection = snapshot.value as? [[String: Any]] {
                completion(collection.count)
            } else {
                completion(0)
            }
        }
    }
    
    func generateConversationId(withMessage message: Message) -> String {
        return "conversation_\(message.messageId)"
    }
    
    func existUser(withUid uid: String) -> AnyPublisher<Bool, Never> {
        
        let userRef = DatabaseEndpoint.user(id: uid).ref
        
        return Future { promise in
            userRef.observeSingleEvent(of: .value, with: { snapshot in
                promise(.success(snapshot.exists()))
            })
        }.eraseToAnyPublisher()
    }
}
