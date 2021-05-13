//
//  DatabaseService.swift
//  chat
//
//  Created by vlsuv on 08.05.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Combine

protocol DatabaseServiceProtocol {
    func insertObjectIntoDatabase<T: Encodable>(reference: DatabaseReference, object: T, completion: @escaping (DatabaseServiceError?) -> ())
    
    func fetchObject<T: Decodable>(reference: DatabaseReference, decodingType: T.Type, eventType: DataEventType) -> AnyPublisher<T, DatabaseServiceError>
    func fetchObject<T: Decodable>(reference: DatabaseReference, decodingType: T.Type, eventType: DataEventType, responce: @escaping (Result<T, DatabaseServiceError>) -> ())
    
    func observeObject<T: Decodable>(reference: DatabaseReference, decodingType: T.Type) -> AnyPublisher<T, Error>
}

enum DatabaseServiceError: Error {
    case FailedToConvertObjectToJson
    case FailedToSetValueIntoDatabase
    case FailedToConvertJsonToObject
}

final class DatabaseService: DatabaseServiceProtocol {
    func insertObjectIntoDatabase<T: Encodable>(reference: DatabaseReference, object: T, completion: @escaping (DatabaseServiceError?) -> ()) {
        guard let json = encodeObject(object: object) else {
            completion(.FailedToConvertObjectToJson)
            return
        }
        
        reference.setValue(json) { error, _ in
            if error != nil {
                completion(.FailedToSetValueIntoDatabase)
                return
            }
            completion(nil)
        }
    }
    
    func fetchObject<T: Decodable>(reference: DatabaseReference, decodingType: T.Type, eventType: DataEventType) -> AnyPublisher<T, DatabaseServiceError> {
        
        return Future { promise in
            reference.observeSingleEvent(of: eventType) { [weak self] snapshot in
                guard let self = self else { return }
                
                guard let decoded = self.decodeSnapshot(snapshot: snapshot, type: decodingType) else {
                    promise(.failure(.FailedToConvertJsonToObject))
                    return
                }
                promise(.success(decoded))
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchObject<T: Decodable>(reference: DatabaseReference, decodingType: T.Type, eventType: DataEventType, responce: @escaping (Result<T, DatabaseServiceError>) -> ()) {
        
        reference.observeSingleEvent(of: eventType) { [weak self] snapshot in
            guard let self = self else { return }
            
            guard let decoded = self.decodeSnapshot(snapshot: snapshot, type: decodingType) else {
                responce(.failure(.FailedToConvertJsonToObject))
                return
            }
            responce(.success(decoded))
        }
    }
    
    func observeObject<T: Decodable>(reference: DatabaseReference, decodingType: T.Type) -> AnyPublisher<T, Error> {
        let publisher = Publishers.FirebaseObservePublisher(query: reference)
        
        return publisher
            .tryMap {
                guard let decoded = self.decodeSnapshot(snapshot: $0, type: decodingType) else { throw DatabaseServiceError.FailedToConvertJsonToObject }
                return decoded
        }
        .eraseToAnyPublisher()
    }
}

extension DatabaseService {
    private func encodeObject<T: Encodable>(object: T) -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(object),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return nil
        }
        return json
    }
    
    private func decodeSnapshot<T: Decodable>(snapshot: DataSnapshot, type: T.Type) -> T? {
        
        guard let value = snapshot.value, JSONSerialization.isValidJSONObject(value) else {
            return nil }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: value)
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            print(error)
            return nil
        }
        
        
        
//        guard let value = snapshot.value as? [String: Any],
//            let data = try? JSONSerialization.data(withJSONObject: value),
//            let objects = try? JSONDecoder().decode(type.self, from: data) else {
//                return nil
//        }
//        return objects
    }
    
    private func decodeJson<T: Decodable>(json: [String: Any], type: T.Type) -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: json)
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            return nil
        }
    }
}
