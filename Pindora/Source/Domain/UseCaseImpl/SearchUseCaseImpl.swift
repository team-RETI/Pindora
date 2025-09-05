//
//  SearchUseCaseImpl.swift
//  Pindora
//
//  Created by eunchanKim on 9/4/25.
//

import Foundation
import Combine
import CoreLocation

final class SearchUseCaseImpl: SearchUseCaseProtocol {
    private let repository: SearchRepositoryProtocol

    init(repository: SearchRepositoryProtocol) {
        self.repository = repository
    }
    
    func search(keyword: String) -> AnyPublisher<[Place], UseCaseError> {
        return repository.search(keyword: keyword)
            .mapError { RepositoryError.map(from: $0) }
            .mapError { UseCaseError.map(from: $0) }
            .eraseToAnyPublisher()
    }
    
    func search(keyword: String, center: CLLocationCoordinate2D?) -> AnyPublisher<[Place], UseCaseError> {
        return repository.search(keyword: keyword)
            .mapError { RepositoryError.map(from: $0) }
            .mapError { UseCaseError.map(from: $0) }
            .eraseToAnyPublisher()
    }
}
