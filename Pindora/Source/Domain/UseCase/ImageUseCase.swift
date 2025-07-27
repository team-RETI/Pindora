//
//  ImageUseCase.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import UIKit
import Combine

protocol ImageUsecaseProtocol {
    func upload(image: UIImage, folder: String, fileName: String) -> AnyPublisher<URL, Error>
    func download(from path: String) -> AnyPublisher<UIImage, Error>
}
