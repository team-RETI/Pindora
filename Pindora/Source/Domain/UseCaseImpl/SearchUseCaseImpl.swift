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
    
    func search(keyword: String, center: CLLocationCoordinate2D) -> AnyPublisher<[Place], UseCaseError> {
        return repository.search(keyword: keyword, center: center)
            .mapError { RepositoryError.map(from: $0) }
            .mapError { UseCaseError.map(from: $0) }
            .eraseToAnyPublisher()
    }
    
    func searchImage(
        query: String,
        display: Int,
        start: Int,
        sort: String,
        filter: String) -> AnyPublisher<[NaverImageResponse.Item], UseCaseError> {
            return  repository.searchImage(query: query, display: display, start: start, sort: sort, filter: filter)
                .mapError { RepositoryError.map(from: $0) }
                .mapError { UseCaseError.map(from: $0) }
                .eraseToAnyPublisher()
    }
    
    func searchGeocode(
        query: String,
        page: Int,
        size: Int) -> AnyPublisher<Place, UseCaseError> {
            return  repository.searchGeocode(query: query, page: page, size: size)
                .mapError { RepositoryError.map(from: $0) }
                .mapError { UseCaseError.map(from: $0) }
                .eraseToAnyPublisher()
    }
}
