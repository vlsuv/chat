//
//  StorageService.swift
//  chat
//
//  Created by vlsuv on 11.05.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import Foundation
import Combine
import FirebaseStorage

enum StorageServiceError: Error {
    case FailedToPutDataIntoStorage
    case FailedToGetData
}

protocol StorageServiceProtocol {
    func putDataIntoStorage(reference: StorageReference, data: Data, metadata: StorageMetadata?) -> AnyPublisher<Void, StorageServiceError>
    func putDataIntoStorage(reference: StorageReference, data: Data, metadata: StorageMetadata?) -> AnyPublisher<URL, StorageServiceError>
    
    func getData(reference: StorageReference, responce: @escaping (Result<Data, StorageServiceError>) -> ())
}

final class StorageService: StorageServiceProtocol {
    
    func putDataIntoStorage(reference: StorageReference, data: Data, metadata: StorageMetadata?) -> AnyPublisher<Void, StorageServiceError> {
        
        return Future { promise in
            reference.putData(data, metadata: metadata) { _, error in
                if error != nil {
                    promise(.failure(.FailedToPutDataIntoStorage))
                    return
                }
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    func putDataIntoStorage(reference: StorageReference, data: Data, metadata: StorageMetadata?) -> AnyPublisher<URL, StorageServiceError> {
        
        return Future { promise in
            reference.putData(data, metadata: metadata) { _, error in
                if error != nil {
                    promise(.failure(.FailedToPutDataIntoStorage))
                    return
                }
                
                reference.downloadURL { url, error in
                    if error != nil {
                        promise(.failure(.FailedToPutDataIntoStorage))
                        return
                    }
                    
                    guard let url = url else {
                        promise(.failure(.FailedToPutDataIntoStorage))
                        return
                    }
                    promise(.success(url))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getData(reference: StorageReference, responce: @escaping (Result<Data, StorageServiceError>) -> ()) {
        reference.getData(maxSize: 1 * 10240 * 10240) { data, error in
            guard error == nil, let data = data else {
                responce(.failure(.FailedToGetData))
                return
            }
            responce(.success(data))
        }
    }
}
