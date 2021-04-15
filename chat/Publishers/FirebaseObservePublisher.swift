//
//  FirebaseObserveSubscription.swift
//  chat
//
//  Created by vlsuv on 12.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Combine
import Firebase

extension Publishers {
    struct FirebaseObservePublisher: Publisher {
            
        typealias Output = DataSnapshot
        typealias Failure = Never
        
        let query: DatabaseQuery
        
        init(query: DatabaseQuery) {
            self.query = query
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = FirebaseObserveSubscription(query: query, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }

    final class FirebaseObserveSubscription<S: Subscriber>: Subscription where S.Input == DataSnapshot, S.Failure == Never {
        
        let query: DatabaseQuery
        var subscriber: S?
        var databaseHandle: DatabaseHandle?
        
        init(query: DatabaseQuery, subscriber: S) {
            self.query = query
            self.subscriber = subscriber
            observeToQuery()
        }
        
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {
            if let databaseHandle = databaseHandle {
                query.removeObserver(withHandle: databaseHandle)
            }
            subscriber = nil
            databaseHandle = nil
        }
        
        func observeToQuery() {
            guard let subscriber = subscriber else { return }
            
            databaseHandle = query.observe(.value, with: { (snapshot) in
                _ = subscriber.receive(snapshot)
            })
        }
    }
}




