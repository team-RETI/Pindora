//
//  PlaceUseCaseImpl.swift
//  Pindora
//
//  Created by 장주진 on 8/4/25.
//

import Foundation
import Combine

final class PlaceUseCaseImpl: PlaceUseCase {
    private let repository: DatabaseRepositoryProtocol
    
    init(repository: DatabaseRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchPlaces() -> AnyPublisher<[Place], any Error> {
        <#code#>
    }
}
