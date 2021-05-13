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
    case FailedToUploadAudio
}

enum StorageEndpoint {
    case userPhoto(uid: String)
    case messagePhoto(messageId: String)
    case messageVideo(messageId: String)
    case messageAudio(messageId: String)
    
    private var storageRef: StorageReference {
        return Storage.storage().reference()
    }
    
    var ref: StorageReference {
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
        case .messageAudio(messageId: let messageId):
            let fileName = "audio_message_\(messageId).mp3"
            let ref = storageRef.child("audio_message/\(fileName)")
            return ref
        }
    }
}

class StorageManager {
    private let storageService: StorageServiceProtocol = StorageService()
    
    static let shared = StorageManager()
    
    private init() {}
}

// MARK: User
extension StorageManager {
    func uploadUserPhotoIntoStorage(userUid: String, photoData: Data) -> AnyPublisher<Void, StorageServiceError> {
        let riversRef = StorageEndpoint.userPhoto(uid: userUid).ref
        return storageService.putDataIntoStorage(reference: riversRef, data: photoData, metadata: nil)
    }
    
    func downloadUserPhoto(userUid: String) -> AnyPublisher<UIImage, Error> {
        let photoRef = StorageEndpoint.userPhoto(uid: userUid).ref
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.storageService.getData(reference: photoRef) { result in
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else { return }
                    promise(.success(image))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - Message Attachments
extension StorageManager {
    // Message Photo
    func uploadMessagePhotoIntoStorage(imageData: Data, messageId: String) -> AnyPublisher<URL, StorageServiceError> {
        let photoRef = StorageEndpoint.messagePhoto(messageId: messageId).ref
        return storageService.putDataIntoStorage(reference: photoRef, data: imageData, metadata: nil)
    }
    
    func downloadMessagePhoto(messageId: String) -> AnyPublisher<UIImage, Never> {
        let photoRef = StorageEndpoint.messagePhoto(messageId: messageId).ref
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.storageService.getData(reference: photoRef) { result in
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else { return }
                    promise(.success(image))
                case .failure(let error):
                    print(error)
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Message Video
    func uploadMessageVideoIntoStorage(url: URL, messageId: String) -> AnyPublisher<URL, StorageServiceError> {
        guard let data = try? Data(contentsOf: url) else { return Fail(error: StorageServiceError.FailedToPutDataIntoStorage).eraseToAnyPublisher() }
        
        let videoRef = StorageEndpoint.messageVideo(messageId: messageId).ref
        
        return storageService.putDataIntoStorage(reference: videoRef, data: data, metadata: nil)
    }
    
    // Message Audio
    func uploadMessageAudioIntoStorage(audioURL: URL, messageId: String) -> AnyPublisher<URL, StorageServiceError> {
        guard let data = try? Data(contentsOf: audioURL) else { return Fail(error: StorageServiceError.FailedToPutDataIntoStorage).eraseToAnyPublisher() }
        
        let audioRef = StorageEndpoint.messageAudio(messageId: messageId).ref
        
        return storageService.putDataIntoStorage(reference: audioRef, data: data, metadata: nil)
    }
}
