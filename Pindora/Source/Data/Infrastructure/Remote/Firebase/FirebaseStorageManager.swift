//
//  FirebaseStorageManager.swift
//  Pindora
//
//  Created by 장주진 on 7/28/25.
//

import FirebaseStorage
import UIKit
import Combine

final class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    private init() {}
    
    private let storage = Storage.storage()
    
    func uploadImage(_ data: Data, to path: String) -> AnyPublisher<URL, Error> {
        Future<URL, Error> { promise in
            let ref = self.storage.reference().child(path)
            ref.putData(data, metadata: nil) { _, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                ref.downloadURL { url, error in
                    if let error = error {
                        promise(.failure(error))
                    } else if let url = url {
                        promise(.success(url))
                    } else {
                        promise(.failure(NSError(domain: "StorageError", code: -1)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func downloadImage(from path: String) -> AnyPublisher<Data, Error> {
        Future<Data, Error> { promise in
            let ref = self.storage.reference(withPath: path)
            ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let error = error {
                    promise(.failure(error))
                } else if let data = data {
                    promise(.success(data))
                } else {
                    promise(.failure(NSError(domain: "ImageError", code: -1)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
