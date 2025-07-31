//
//  ImageUseCaseImpl.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import UIKit
import Combine

final class ImageUsecaseImpl: ImageUsecaseProtocol {
    private let storageRepository: StorageRepositoryProtocol
    
    init(storageRepository: StorageRepositoryProtocol) {
        self.storageRepository = storageRepository
    }
    
    func upload(image: UIImage, folder: String, fileName: String) -> AnyPublisher<URL, any Error> {
        return storageRepository.uploadImage(image, to: folder, with: fileName)
    }
    
    func download(from path: String) -> AnyPublisher<UIImage, any Error> {
        return storageRepository.downloadImage(from: path)
    }
}
