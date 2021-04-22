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
    case FailedToUploadVideo
}

enum StorageEndpoint {
    case userPhoto(uid: String)
    case messagePhoto(messageId: String)
    case messageVideo(messageId: String)
    
    private var storageRef: StorageReference {
        return Storage.storage().reference()
    }
    
    var getRef: StorageReference {
        switch self {
        case .userPhoto(uid: let uid):
            let fileName = "\(uid)_user_photo.png"
            let ref = storageRef.child("images/\(fileName)")
            return ref
        case .messagePhoto(messageId: let messageId):
            let fileName = "photo_message_\(messageId).png"
            let ref = storageRef.child("message_photos/\(fileName)")
            return ref
        case .messageVideo(messageId: let messageId):
            let fileName = "video_message_\(messageId).mov"
            let ref = storageRef.child("message_videos/\(fileName)")
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
    
    func uploadMessagePhotoIntoStorage(imageData: Data, messageId: String) -> AnyPublisher<String, StorageError> {
        let photoRef = StorageEndpoint.messagePhoto(messageId: messageId).getRef
        
        return Future { promise in
            photoRef.putData(imageData, metadata: nil) { data, error in
                if error != nil {
                    promise(.failure(.FailedToUploadImage))
                    return
                }
                
                photoRef.downloadURL { url, error in
                    if error != nil {
                        promise(.failure(.FailedToUploadImage))
                        return
                    }
                    
                    guard let urlString = url?.absoluteString else {
                        promise(.failure(.FailedToUploadImage))
                        return
                    }
                    
                    promise(.success(urlString))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func downloadMessagePhoto(messageId: String) -> AnyPublisher<UIImage, Never> {
        let photoRef = StorageEndpoint.messagePhoto(messageId: messageId).getRef
        
        return Future { promise in
            photoRef.getData(maxSize: 1 * 10240 * 10240) { data, error in
                if error != nil {
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else { return }
                promise(.success(image))
            }
        }.eraseToAnyPublisher()
    }
    
    func uploadMessageVideoIntoStorage(url: URL, messageId: String) -> AnyPublisher<String, StorageError> {
        let videoRef = StorageEndpoint.messageVideo(messageId: messageId).getRef
        
        return Future { promise in
             guard let videoData = try? Data(contentsOf: url) else { return }
            
            videoRef.putData(videoData, metadata: nil) { _, error in
                if error != nil {
                    promise(.failure(.FailedToUploadVideo))
                    return
                }
                
                videoRef.downloadURL { url, error in
                    if error != nil {
                        promise(.failure(.FailedToUploadVideo))
                        return
                    }
                    
                    guard let urlString = url?.absoluteString else { return }
                    
                    promise(.success(urlString))
                }
            }
        }.eraseToAnyPublisher()
    }
}
