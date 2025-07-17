//
//  UploadImageUsecase.swift
//  Pindora
//
//  Created by 장주진 on 7/17/25.
//

import UIKit

final class ImageUsecase {
    private let storageRepository: StorageRepositoryProtocol
    
    init(storageRepository: StorageRepositoryProtocol) {
        self.storageRepository = storageRepository
    }
    
    func upload(image: UIImage, folder: String, fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        storageRepository.uploadImage(image, to: folder, with: fileName, completion: completion)
    }
    
    func download(from path: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        storageRepository.downloadImage(from: path, completion: completion)
    }
}
