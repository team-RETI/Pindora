//
//  SearchUseCaseProtocol.swift
//  Pindora
//
//  Created by eunchanKim on 9/4/25.
//

import UIKit
import Combine
import CoreLocation

/// 외부 API를 이용하여  장소정보를 검색하는 유즈케이스입니다.
protocol SearchUseCaseProtocol {
    
    /// 키워드를 이용하여 장소를 겁색합니다
    /// - Parameter keyword: 사용자 입력 키워드
    /// - Returns: 장소리스트 AnyPublisher<[Place], UseCaseError>
    func search(keyword: String) -> AnyPublisher<[Place], UseCaseError>
    
    /// 위치정보와 키워드를 이용하여 장소를 검색합니다
    /// - Parameters:
    ///   - keyword: 사용자 입력 키워드
    ///   - center: 위치 정보(좌표)
    /// - Returns: 장소리스트 AnyPublisher<[Place], UseCaseError>
    func search(keyword: String, center: CLLocationCoordinate2D?) -> AnyPublisher<[Place], UseCaseError>
}
