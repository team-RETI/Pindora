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
    private let searchImageManager: NaverImageAPIManager
    
    init(
        searchManager: KakaoSearchAPIManager = KakaoSearchAPIManager(),
        searchImageManager: NaverImageAPIManager = NaverImageAPIManager()
    ) {
        self.searchManager = searchManager
        self.searchImageManager = searchImageManager
    }
    
    func search(keyword: String) -> AnyPublisher<[Place], InfraError> {
        searchManager.searchPlaces(keyword: keyword, x: 0.0, y: 0.0)
            .eraseToAnyPublisher()
    }
    
    func search(keyword: String, center: CLLocationCoordinate2D) -> AnyPublisher<[Place], InfraError> {
        searchManager.searchPlaces(keyword: keyword, x: center.longitude, y: center.latitude)
            .eraseToAnyPublisher()
    }
    
    func searchImage(
        query: String,
        display: Int,
        start: Int,
        sort: String,
        filter: String) -> AnyPublisher<[NaverImageResponse.Item], InfraError> {
            return  searchImageManager.searchImage(query: query, display: display, start: start, sort: sort, filter: filter)
                .eraseToAnyPublisher()
    }
}
