//
//  LocationRepositoryImpl.swift
//  Pindora
//
//  Created by eunchanKim on 9/1/25.
//

import Foundation
import Combine
import CoreLocation

/// 실제 위치 정보를 다루는 구현체
final class LocationRepositoryImpl: NSObject, LocationRepositoryProtocol {
    private let locationManager: CLLocationManager
    private let authorizationStatusSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    private let errorSubject = PassthroughSubject<Void ,InfraError>()
    

    // 퍼블리셔로 외부에 노출
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationStatusSubject.eraseToAnyPublisher()
    }

    var locationPublisher: AnyPublisher<CLLocation, Never> {
        locationSubject.eraseToAnyPublisher()
    }

    var errorPublisher: AnyPublisher<Void, InfraError> {
        errorSubject.eraseToAnyPublisher()
    }

    // 초기화
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
    }

    /// 위치 권한 요청
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// 위치 업데이트 시작
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }

    /// 위치 업데이트 중지
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationRepositoryImpl: CLLocationManagerDelegate {
    /// 권한 상태 변경 시 호출
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        authorizationStatusSubject.send(status)
    }

    /// 새로운 위치 업데이트 시 호출
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        locationSubject.send(latest)
    }

    /// 위치 업데이트 실패 시 호출
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ 위치 업데이트 실패: \(error.localizedDescription)")
    }
}
