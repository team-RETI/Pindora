//
//  FirebaseStorageManager.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation
import FirebaseStorage
import Combine

final class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    
    func uploadImage(_ data: Data, to path: String) -> AnyPublisher<URL, Error> {
        let ref = Storage.storage().reference().child(path)
        return Future<URL, Error> { promise in
            ref.putData(data, metadata: nil) { _, error in
                if let error {
                    promise(.failure(error))
                } else {
                    ref.downloadURL { url, error in
                        if let url {
                            promise(.success(url))
                        } else {
                            promise(.failure(error ?? NSError(domain: "UploadError", code: -1)))
                        }
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func downloadImage(from path: String) -> AnyPublisher<Data,Error> {
        let ref = Storage.storage().reference().child(path)
        return Future<Data, Error> { promise in
            ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let data {
                    promise(.success(data))
                } else {
                    promise(.failure(error ?? NSError(domain: "DownloadError", code: -1)))
                }
            }
        }.eraseToAnyPublisher()
    }
}
