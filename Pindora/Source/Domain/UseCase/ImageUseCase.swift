//
//  ImageUseCase.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import UIKit

protocol ImageUsecaseProtocol {
    func upload(image: UIImage, folder: String, fileName: String, completion: @escaping (Result<URL, Error>) -> Void)
    func download(from path: String, completion: @escaping (Result<UIImage, Error>) -> Void)
}
