//
//  StorageRepository.swift
//  Pindora
//
//  Created by 장주진 on 7/16/25.
//

import UIKit

public protocol StorageRepositoryProtocol {
    func uploadImage(_ image: UIImage, to folder: String, with fileName: String, completion: @escaping (Result<URL, Error>) -> Void)
}
