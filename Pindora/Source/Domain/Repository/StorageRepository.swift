//
//  StorageRepository.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import UIKit

public protocol StorageRepositoryProtocol {
    func uploadImage(_ image: UIImage, to folder: String, with fileName: String, completion: @escaping (Result<URL, Error>) -> Void)
    func downloadImage(from path: String, completion: @escaping (Result<UIImage, Error>) -> Void)
}
