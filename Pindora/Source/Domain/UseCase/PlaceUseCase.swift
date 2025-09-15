//
//  PlaceUseCase.swift
//  Pindora
//
//  Created by 장주진 on 8/4/25.
//

import Foundation
import Combine

protocol PlaceUseCase {
    func fetchPlaces() -> AnyPublisher<[Place], Error>
    
    
    /// 파이어베이스에서 고정 키워드들을 가져오는 함수
    /// - Returns: AnyPublisher<[String], Error>
    func fetchKeywords() -> AnyPublisher<[String], Error>
}
