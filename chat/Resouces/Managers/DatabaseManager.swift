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
    
    static let shared = DatabaseManager()
    private init() {}
    
    var ref = Database.database().reference()
    
    func generateConversationId(withMessage message: Message) -> String {
        return "conversation_\(message.messageId)"
    }
    
}

// MARK: - User Manage
extension DatabaseManager {
    func insertUserIntoDatabase(_ user: AppUser) -> AnyPublisher<Void, DatabaseError> {
        let userRef = DatabaseEndpoint.user(id: user.senderId).ref
        let usersRef = DatabaseEndpoint.users.ref
        
        return Future { promise in
            guard let userJsonData = try? JSONEncoder().encode(user),
                let userJson = try? JSONSerialization.jsonObject(with: userJsonData) as? [String: Any] else {
                    promise(.failure(.FailedToAddUser))
                    return
            }
            
            userRef.setValue(userJson, withCompletionBlock: { error, _ in
                if error != nil {
                    promise(.failure(.FailedToAddUser))
                    return
                }
            })
            
            usersRef.observeSingleEvent(of: .value, with: { snapshot in
                if var userCollection = snapshot.value as? [[String: Any]] {
                    userCollection.append(userJson)
                    usersRef.setValue(userCollection, withCompletionBlock: { error, _ in
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
                    usersRef.setValue(newUserCollection, withCompletionBlock: { error, _ in
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
        let userRef = DatabaseEndpoint.user(id: uid).ref
        
        return Future { promise in
            userRef.observeSingleEvent(of: .value, with: { snapshot in
                promise(.success(snapshot.exists()))
            })
        }.eraseToAnyPublisher()
    }
    
    func fetchAllUsers() -> AnyPublisher<[AppUser], DatabaseError> {
        let usersRef = DatabaseEndpoint.users.ref
        
        return Future { promise in
            usersRef.observeSingleEvent(of: .value, with: { snapshot in
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
        let conversationId: String = generateConversationId(withMessage: message)
        let messagesRef = DatabaseEndpoint.messages(conversationId: conversationId).ref
        
        return Future { [weak self] promise in
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
            messagesRef.setValue(messageCollection, withCompletionBlock: { error, _ in
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
        let conversationsRef = DatabaseEndpoint.conversations(user: user).ref
        
        guard let conversationData = try? JSONEncoder().encode(conversation),
            let conversationDict = try? JSONSerialization.jsonObject(with: conversationData) as? [String: Any] else {
                return
        }
        
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
    
    func deleteConversation(_ conversation: Conversation, user: AppUser) -> AnyPublisher<Void, DatabaseError> {
        let conversationsRef = DatabaseEndpoint.conversations(user: user).ref
        
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

// MARK: Message Manage
extension DatabaseManager {
    func sendMessage(to conversation: Conversation, message: Message) -> AnyPublisher<Void, DatabaseError> {
        let messagesRef = DatabaseEndpoint.messages(conversationId: conversation.id).ref
        
        return Future { [weak self] promise in
            guard let messageData = try? JSONEncoder().encode(message),
                let messageDict = try? JSONSerialization.jsonObject(with: messageData) as? [String: Any] else {
                    return
            }
            
            messagesRef.observeSingleEvent(of: .value, with: { snapshot in
                guard var messagesCollection = snapshot.value as? [[String: Any]] else {
                    promise(.failure(.FailedToSendMessage))
                    return
                }
                
                messagesCollection.append(messageDict)
                
                messagesRef.setValue(messagesCollection, withCompletionBlock: { error, _ in
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
        let conversationsRef = DatabaseEndpoint.conversations(user: user).ref
        
        conversationsRef.observeSingleEvent(of: .value) { snapshot in
            guard let conversationsCollection = snapshot.value as? [[String: Any]],
                let conversationsData = try? JSONSerialization.data(withJSONObject: conversationsCollection),
                let conversations = try? JSONDecoder().decode([Conversation].self, from: conversationsData) else { return }
            
            guard let index = conversations.firstIndex(where: { $0.id == conversation.id }) else { return }
            
            conversationsRef.child("\(index)/lastMessage").setValue(messageDict)
        }
    }
    
    func observeForAllConversations(user: AppUser) -> AnyPublisher<[Conversation], Never> {
        let conversationsRef = DatabaseEndpoint.conversations(user: user).ref
        let observePublisher = Publishers.FirebaseObservePublisher(query: conversationsRef)
        
        return observePublisher
            .map { guard let value = $0.value as? [[String: Any]],
                let data = try? JSONSerialization.data(withJSONObject: value),
                let conversations = try? JSONDecoder().decode([Conversation].self, from: data) else { return [Conversation]() }
                return conversations }
            .eraseToAnyPublisher()
    }
    
    func observeForAllMesages(conversationId: String) -> AnyPublisher<[Message], Never> {
        let messagesRef = DatabaseEndpoint.messages(conversationId: conversationId).ref
        let observePublisher = Publishers.FirebaseObservePublisher(query: messagesRef)
        
        return observePublisher
            .map { guard let value = $0.value as? [[String: Any]],
                let messagesJsonData = try? JSONSerialization.data(withJSONObject: value),
                let messages = try? JSONDecoder().decode([Message].self, from: messagesJsonData) else { return [Message]() }
                return messages }
            .eraseToAnyPublisher()
    }
}
