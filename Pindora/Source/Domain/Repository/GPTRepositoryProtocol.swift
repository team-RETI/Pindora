//
//  GPTRepositoryProtocol.swift
//  Pindora
//
//  Created by 장주진 on 9/2/25.
//

import Foundation
import Combine

protocol GPTRepositoryProtocol {
    /// 프롬프트를 기반으로 페르소나 작성합니다
    /// - Parameter input: 프롬프트
    /// - Returns: 페르소나를 String으로 방출  AnyPublisher<String, Error>
    func generateDescription(for input: String) -> AnyPublisher<String, Error>
}
