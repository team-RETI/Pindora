//
//  LocationUseCaseProtocol.swift
//  Pindora
//
//  Created by eunchanKim on 8/31/25.
//

import Foundation
import Combine
import CoreLocation

/// 위치 권한 및 위치 업데이트를 담당하는 유즈케이스
protocol LocationUseCaseProtocol {
    
    /// 위치 권한 상태를 스트리밍하는 퍼블리셔
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
    
    /// 위치 업데이트를 스트리밍하는 퍼블리셔
    var locationPublisher: AnyPublisher<CLLocation, Never> { get }

    /// 위치 권한 요청 (보통 최초 실행 시 사용)
    func requestAuthorization()

    /// 위치 업데이트 시작
    func startUpdatingLocation()

    /// 위치 업데이트 중지
    func stopUpdatingLocation()

    /// 위치 권한이 있는지 검사하고, 콜백으로 결과 반환
    func ensureLocationAuthorized(_ completion: @escaping (Bool) -> Void)
    
}

