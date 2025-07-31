//
//  StorageRepositoryImpl.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import FirebaseStorage
import UIKit
import Combine

final class StorageRepositoryImpl: StorageRepositoryProtocol {
    func uploadImage(_ image: UIImage, to folder: String, with fileName: String) -> AnyPublisher<URL, any Error> {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return Fail(error: NSError(domain: "ImageError", code: -1)).eraseToAnyPublisher()
        }
        let path = "\(folder)/\(fileName).jpg"
        return FirebaseStorageManager.shared.uploadImage(data, to: path)
    }
    
    func downloadImage(from path: String) -> AnyPublisher<UIImage, any Error> {
        return FirebaseStorageManager.shared.downloadImage(from: path).tryMap { data in
            guard let image = UIImage(data: data) else {
                throw NSError(domain: "InvalidImage", code: -1)
            }
            return image
        }.eraseToAnyPublisher()
    }
}
