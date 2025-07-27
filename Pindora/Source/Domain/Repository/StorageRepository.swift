//
//  StorageRepository.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import UIKit
import Combine

/// 저장소 관련 작업을 처리하는 프로토콜입니다.
/// 이미지 업로드 및 다운로드 기능을 제공합니다.
public protocol StorageRepositoryProtocol {
    
    /// 이미지를 Firebase Storage에 업로드합니다.
    /// - Parameters:
    ///   - image: 업로드할 UIImage 객체입니다.
    ///   - folder: 이미지를 저장할 Firebase Storage의 폴더 경로입니다.
    ///   - fileName: 저장될 이미지의 파일 이름입니다.
    /// - Returns: 업로드된 이미지의 다운로드 URL을 반환하는 AnyPublisher<URL, Error>입니다.
    func uploadImage(_ image: UIImage, to folder: String, with fileName: String) -> AnyPublisher<URL, Error>
    
    /// Firebase Storage로부터 이미지를 다운로드합니다.
    /// - Parameter path: 다운로드할 이미지의 전체 경로입니다. (예: "Users/user123.jpg")
    /// - Returns: 다운로드된 UIImage 객체를 반환하는 AnyPublisher<UIImage, Error>입니다.
    func downloadImage(from path: String) -> AnyPublisher<UIImage, Error>
}
