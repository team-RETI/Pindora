//
//  ImageUseCase.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import UIKit
import Combine

/// 이미지 업로드 및 다운로드를 처리하는 유스케이스 프로토콜입니다.
/// Firebase Storage를 통해 이미지를 업로드하거나 다운로드합니다.
protocol ImageUsecaseProtocol {
    
    /// 이미지를 지정한 폴더에 업로드하고 해당 이미지의 다운로드 URL을 반환합니다.
    /// - Parameters:
    ///   - image: 업로드할 `UIImage`입니다.
    ///   - folder: 저장할 Firebase Storage 폴더 이름입니다.
    ///   - fileName: 저장할 이미지의 파일 이름입니다.
    /// - Returns: 이미지의 다운로드 URL을 방출하는 AnyPublisher<URL, Error>입니다.
    func upload(image: UIImage, folder: String, fileName: String) -> AnyPublisher<URL, Error>
    
    /// Firebase Storage에서 지정한 경로의 이미지를 다운로드합니다.
    /// - Parameter path: 다운로드할 이미지의 Firebase Storage 경로입니다.
    /// - Returns: 다운로드된 `UIImage`를 방출하는 AnyPublisher<UIImage, Error>입니다.
    func download(from path: String) -> AnyPublisher<UIImage, Error>
}
