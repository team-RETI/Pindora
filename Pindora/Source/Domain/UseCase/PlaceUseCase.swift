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
    
    /// 사용자 정보를 Firestore에 저장합니다.
    /// - Parameter place: 저장할 장소 정보 (Place Model).
    /// - Returns: 작업 완료 여부를 방출하는 AnyPublisher<Void, UseCaseError>
    func savePlace(place: Place) -> AnyPublisher<Void, UseCaseError>
}
