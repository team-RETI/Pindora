//
//  SearchRepositoryProtocol.swift
//  Pindora
//
//  Created by eunchanKim on 9/4/25.
//

import Foundation
import CoreLocation
import Combine

protocol SearchRepositoryProtocol {
    
    /// 키워드를 이용하여 장소를 겁색합니다
    /// - Parameter keyword: 사용자 입력 키워드
    /// - Returns: 장소리스트 AnyPublisher<[Place], UseCaseError>
    func search(keyword: String) -> AnyPublisher<[Place], InfraError>
    
    /// 위치정보와 키워드를 이용하여 장소를 검색합니다
    /// - Parameters:
    ///   - keyword: 사용자 입력 키워드
    ///   - center: 위치 정보(좌표)
    /// - Returns: 장소리스트 AnyPublisher<[Place], UseCaseError>
    func search(keyword: String, center: CLLocationCoordinate2D) -> AnyPublisher<[Place], InfraError>
}
