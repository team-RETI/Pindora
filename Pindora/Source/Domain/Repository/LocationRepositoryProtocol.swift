//
//  LocationRepositoryProtocol.swift
//  Pindora
//
//  Created by eunchanKim on 9/1/25.
//

import Combine
import CoreLocation

/// 위치 관련 로직을 추상화한 Repository
protocol LocationRepositoryProtocol {
    /// CLLocationManager 권한 상태를 퍼블리셔로 제공
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }

    /// CLLocationManager 위치 업데이트 정보를 퍼블리셔로 제공
    var locationPublisher: AnyPublisher<CLLocation, Never> { get }

    /// 위치 권한 요청
    func requestWhenInUseAuthorization()

    /// 위치 업데이트 시작
    func startUpdating()

    /// 위치 업데이트 중단
    func stopUpdating()
    
    /// [변경 예정]
    var errorPublisher: AnyPublisher<LocationError, Never> { get }
}
// [변경예정]
enum LocationError: Error {
    case authorizationDenied
    case authorizationRestricted
    case locationUpdateFailed(Error)
}
