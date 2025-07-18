//
//  FirebaseStorageManager.swift
//  Pindora
//
//  Created by 장주진 on 7/18/25.
//

import Foundation
import FirebaseStorage

final class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    
    func uploadImage(_ data: Data, to path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = Storage.storage().reference().child(path)
        ref.putData(data, metadata: nil) { _, error in
            if let error {
                completion(.failure(error))
            } else {
                ref.downloadURL { url, error in
                    if let url {
                        completion(.success(url))
                    } else {
                        completion(.failure(error ?? NSError(domain: "UploadError", code: -1)))
                    }
                }
            }
        }
    }
    
    func downloadImage(from path: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let ref = Storage.storage().reference().child(path)
        ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let data {
                completion(.success(data))
            } else {
                completion(.failure(error ?? NSError(domain: "DownloadError", code: -1)))
            }
        }
    }
}
