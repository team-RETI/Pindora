//
//  StorageRepositoryImpl.swift
//  Pindora
//
//  Created by 장주진 on 7/16/25.
//

import FirebaseStorage
import UIKit

final class StroageRepeatedlyImpl: StorageRepositoryProtocol {
    func uploadImage(_ image: UIImage, to folder: String, with fileName: String, completion: @escaping (Result<URL, any Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return completion(.failure(NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 변환 실패"])))
        }
        
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("\(folder)/\(fileName).jpg")
        
        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error {
                return completion(.failure(error))
            } else {
                imageRef.downloadURL { url, error in
                    if let url {
                        completion(.success(url))
                    } else if let error {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
