//
//  SearchRepositoryImpl.swift
//  Pindora
//
//  Created by eunchanKim on 9/4/25.
//

import Foundation
import CoreLocation
import Combine

final class SearchRepositoryImpl: SearchRepositoryProtocol {
    private let searchManager: KakaoSearchAPIManager
    
    init(searchManager: KakaoSearchAPIManager = KakaoSearchAPIManager()) {
        self.searchManager = searchManager
    }
    
    func search(keyword: String) -> AnyPublisher<[Place], InfraError> {
        searchManager.searchPlaces(keyword: keyword, x: 1.0, y: 1.0)
            .eraseToAnyPublisher()
    }
    
    func search(keyword: String, center: CLLocationCoordinate2D?) -> AnyPublisher<[Place], InfraError> {
        searchManager.searchPlaces(keyword: keyword, x: 1.0, y: 1.0)
            .eraseToAnyPublisher()
    }
}
