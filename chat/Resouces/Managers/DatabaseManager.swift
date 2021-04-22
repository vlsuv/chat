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
    case FailedToCreateNewChat
    case FailedToCreateNewChatForOtherUser
    case FailedToSendMessage
    case FailedToDeleteConversation
}

class DatabaseManager {
    
    static let shared = DatabaseManager()
    private init() {}
    
    var ref = Database.database().reference()
    
}

// MARK: - Users Manage
extension DatabaseManager {
    
    func insertUserIntoDatabase(_ user: AppUser) -> AnyPublisher<Void, DatabaseError> {
        return Future { [weak self] promise in
            guard let userJsonData = try? JSONEncoder().encode(user),
                let userJson = try? JSONSerialization.jsonObject(with: userJsonData) as? [String: Any] else {
                    promise(.failure(.FailedToAddUser))
                    return
            }
            
            self?.ref.child(user.senderId).setValue(userJson, withCompletionBlock: { error, _ in
                if error != nil {
                    promise(.failure(.FailedToAddUser))
                    return
                }
            })
            
            self?.ref.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var userCollection = snapshot.value as? [[String: Any]] {
                    userCollection.append(userJson)
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
                        userJson
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

// MARK: - Conversations Manage
extension DatabaseManager {
    func createConversation(otherUser: AppUser, message: Message) -> AnyPublisher<Conversation, DatabaseError> {
        return Future { [weak self] promise in
            let conversationId: String = "conversation_\(message.messageId)"
            
            let users: [AppUser] = [otherUser, message.user]
            
            for (index, user) in users.enumerated() {
                self?.addConversationIntoUserCollection(user: user,
                                                        conversation: Conversation(id: conversationId,
                                                                                   otherUser: users[(index + 1) % users.count],
                                                                                   lastMessage: message))
            }
            
            guard let messageData = try? JSONEncoder().encode(message),
                let messageDict = try? JSONSerialization.jsonObject(with: messageData) as? [String: Any] else {
                    return
            }
            
            let messageCollection: [[String: Any]] = [ messageDict ]
            self?.ref.child("\(conversationId)/messages").setValue(messageCollection, withCompletionBlock: { error, _ in
                if error != nil {
                    promise(.failure(.FailedToCreateNewChat))
                    return
                }
                
                let conversation = Conversation(id: conversationId, otherUser: otherUser, lastMessage: message)
                promise(.success(conversation))
            })
        }
        .eraseToAnyPublisher()
    }
    
    private func addConversationIntoUserCollection(user: AppUser, conversation: Conversation) {
        guard let conversationData = try? JSONEncoder().encode(conversation),
            let conversationDict = try? JSONSerialization.jsonObject(with: conversationData) as? [String: Any] else {
                return
        }
        
        let conversationsRef = self.ref.child("\(user.senderId)/conversations")
        
        conversationsRef.observeSingleEvent(of: .value) { snapshot in
            if var conversationsCollection = snapshot.value as? [[String: Any]] {
                conversationsCollection.append(conversationDict)
                conversationsRef.setValue(conversationsCollection)
            } else {
                let conversationCollection: [[String: Any]] = [ conversationDict ]
                conversationsRef.setValue(conversationCollection)
            }
        }
    }
    
    func sendMessage(to conversation: Conversation, message: Message) -> AnyPublisher<Void, DatabaseError> {
        return Future { [weak self] promise in
            guard let messageData = try? JSONEncoder().encode(message),
                let messageDict = try? JSONSerialization.jsonObject(with: messageData) as? [String: Any] else {
                    return
                    }
            
            self?.ref.child("\(conversation.id)/messages").observeSingleEvent(of: .value, with: { snapshot in
                guard var messagesCollection = snapshot.value as? [[String: Any]] else {
                    promise(.failure(.FailedToSendMessage))
                    return
                }
                
                messagesCollection.append(messageDict)
                
                self?.ref.child("\(conversation.id)/messages").setValue(messagesCollection, withCompletionBlock: { error, _ in
                    if error != nil {
                        promise(.failure(.FailedToSendMessage))
                        return
                    }
                })
            })
            
            let users: [AppUser] = [message.user, conversation.otherUser]
            
            for user in users {
                self?.sendMessageIntoUserCollection(user: user, conversation: conversation, messageDict: messageDict)
            }
            
        }.eraseToAnyPublisher()
    }
    
    private func sendMessageIntoUserCollection(user: AppUser, conversation: Conversation, messageDict: [String: Any] ) {
        let conversationsRef = ref.child("\(user.senderId)/conversations")
        
        conversationsRef.observeSingleEvent(of: .value) { snapshot in
            guard let conversationsCollection = snapshot.value as? [[String: Any]],
                let conversationsData = try? JSONSerialization.data(withJSONObject: conversationsCollection),
                let conversations = try? JSONDecoder().decode([Conversation].self, from: conversationsData) else { return }
            
            guard let index = conversations.firstIndex(where: { $0.id == conversation.id }) else { return }
            
            conversationsRef.child("\(index)/lastMessage").setValue(messageDict)
        }
    }
    
    func observeForAllConversations(userUid: String) -> AnyPublisher<[Conversation], Never> {
        let query = ref.child("\(userUid)/conversations")
        let observePublisher = Publishers.FirebaseObservePublisher(query: query)
        
        return observePublisher
            .map { guard let value = $0.value as? [[String: Any]],
                let data = try? JSONSerialization.data(withJSONObject: value),
                let conversations = try? JSONDecoder().decode([Conversation].self, from: data) else { return [Conversation]() }
                return conversations }
            .eraseToAnyPublisher()
    }
    
    func observeForAllMesages(conversationId: String) -> AnyPublisher<[Message], Never> {
        let query = ref.child("\(conversationId)/messages")
        let observePublisher = Publishers.FirebaseObservePublisher(query: query)
        
        return observePublisher
            .map { guard let value = $0.value as? [[String: Any]],
                let messagesJsonData = try? JSONSerialization.data(withJSONObject: value),
                let messages = try? JSONDecoder().decode([Message].self, from: messagesJsonData) else { return [Message]() }
                return messages }
            .eraseToAnyPublisher()
    }
    
    func deleteConversation(_ conversation: Conversation, user: AppUser) -> AnyPublisher<Void, DatabaseError> {
        let conversationsRef = ref.child("\(user.senderId)/conversations")
        
        return Future { promise in
            conversationsRef.observeSingleEvent(of: .value) { snapshot in
                guard var conversationCollection = snapshot.value as? [[String: Any]],
                    let conversationData = try? JSONSerialization.data(withJSONObject: conversationCollection),
                    let conversations = try? JSONDecoder().decode([Conversation].self, from: conversationData) else {
                        promise(.failure(.FailedToDeleteConversation))
                        return
                }
                
                guard let index = conversations.firstIndex(where: { $0.id == conversation.id }) else {
                    promise(.failure(.FailedToDeleteConversation))
                    return
                }
                
                conversationCollection.remove(at: index)
                
                conversationsRef.setValue(conversationCollection) { error, _ in
                    if error != nil {
                        promise(.failure(.FailedToDeleteConversation))
                        return
                    }
                    
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}
