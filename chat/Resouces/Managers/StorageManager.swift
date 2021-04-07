//
//  StorageManager.swift
//  chat
//
//  Created by vlsuv on 07.04.2021.
//  Copyright © 2021 vlsuv. All rights reserved.
//

import UIKit
import FirebaseStorage
import Combine

enum StorageError: Error {
    case FailedToUploadImage
    case FailedToDownloadUserPhoto
}

enum StorageEndpoint {
    case userPhoto(uid: String)
    
    private var storageRef: StorageReference {
        return Storage.storage().reference()
    }
    
    var getRef: StorageReference {
        switch self {
        case .userPhoto(uid: let uid):
            let fileName = "\(uid)_user_photo.png"
            let ref = storageRef.child("images/\(fileName)")
            return ref
        }
    }
}

class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    
}

extension StorageManager {
    
    func uploadUserPhotoIntoStorage(userUid: String, photoData: Data) -> AnyPublisher<Void, StorageError> {
        let riversRef = StorageEndpoint.userPhoto(uid: userUid).getRef
        
        return Future { promise in
            riversRef.putData(photoData, metadata: nil) { _, error in
                if error != nil {
                    promise(.failure(.FailedToUploadImage))
                    return
                }
                
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    func downloadUserPhoto(userUid: String) -> AnyPublisher<UIImage, StorageError> {
        let photoRef = StorageEndpoint.userPhoto(uid: userUid).getRef
        
        return Future { promise in
            photoRef.getData(maxSize: 1 * 10240 * 10240) { data, error in
                if error != nil {
                    promise(.failure(.FailedToDownloadUserPhoto))
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    promise(.failure(.FailedToDownloadUserPhoto))
                    return
                }
                promise(.success(image))
            }
        }.eraseToAnyPublisher()
    }
}
