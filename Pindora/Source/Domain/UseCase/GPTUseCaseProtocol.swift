//
//  GPTUseCaseProtocol.swift
//  Pindora
//
//  Created by 장주진 on 9/2/25.
//

import Foundation
import Combine

protocol GPTUseCaseProtocol {
    /// 페르소나를 제작하기 위한 키워드
    /// - Parameter keyword: 유저가 방문한 장소키워드
    /// - Returns: 유저 개인의 페르소나 이름과 설명 AnyPublisher<(name: String, description: String), Error>
    func createPersonaNameAndDescription(from keyword: [String]) -> AnyPublisher<(name: String, description: String), Error>
}
