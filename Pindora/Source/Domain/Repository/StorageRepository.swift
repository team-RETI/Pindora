//
//  StorageRepository.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import UIKit
import Combine

public protocol StorageRepositoryProtocol {
    func uploadImage(_ image: UIImage, to folder: String, with fileName: String) -> AnyPublisher<URL, Error>
    func downloadImage(from path: String) -> AnyPublisher<UIImage, Error>
}
