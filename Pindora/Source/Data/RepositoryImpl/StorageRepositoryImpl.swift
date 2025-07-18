//
//  StorageRepositoryImpl.swift
//  Pindora
//
//  Created by 장주진 on 7/16/25.
//

import FirebaseStorage
import UIKit

final class StorageRepositoryImpl: StorageRepositoryProtocol {
    func uploadImage(_ image: UIImage, to folder: String, with fileName: String, completion: @escaping (Result<URL, any Error>) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageError", code: -1)))
            return
        }
        
        let path = "\(folder)/\(fileName).jpg"
        FirebaseStorageManager.shared.uploadImage(data, to: path, completion: completion)
    }
    
    func downloadImage(from path: String, completion: @escaping (Result<UIImage, any Error>) -> Void) {
        FirebaseStorageManager.shared.downloadImage(from: path) { result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(NSError(domain: "InvaildImage", code: -1)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
