//
//  LocationUseCaseImpl.swift
//  Pindora
//
//  Created by eunchanKim on 8/31/25.
//

import Foundation
import Combine
import CoreLocation

/// LocationUseCase 프로토콜의 실제 구현체
final class LocationUseCaseImpl: LocationUseCaseProtocol {

    // MARK: - 의존성 주입
    private let locationRepository: LocationRepositoryProtocol

    // MARK: - Combine 저장소
    private var cancellables = Set<AnyCancellable>()

    // MARK: - 퍼블리셔 전달
    /// 권한 상태 퍼블리셔는 내부적으로 레포지토리의 것을 그대로 사용
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        locationRepository.authorizationStatusPublisher
    }

    /// 위치 업데이트 퍼블리셔도 레포지토리로부터 전달받음
    var locationPublisher: AnyPublisher<CLLocation, Never> {
        locationRepository.locationPublisher
    }

    // MARK: - 초기화
    init(repository: LocationRepositoryProtocol) {
        self.locationRepository = repository
    }

    // MARK: - 위치 관련 메서드

    /// 위치 권한 요청 (앱 실행 초기에 사용)
    func requestAuthorization() {
        locationRepository.requestWhenInUseAuthorization()
    }

    /// 위치 업데이트 시작 (startUpdatingLocation 호출 시 위치 받아오기 시작)
    func startUpdatingLocation() {
        locationRepository.startUpdating()
    }

    /// 위치 업데이트 중지
    func stopUpdatingLocation() {
        locationRepository.stopUpdating()
    }

    /// 현재 위치 권한이 있는지 확인하고 콜백으로 결과 전달
    func ensureLocationAuthorized(_ completion: @escaping (Bool) -> Void) {
        locationRepository.authorizationStatusPublisher
            .first() // 최초 값 1회만 받음
            .sink { status in
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    completion(true)
                default:
                    completion(false)
                }
            }
            .store(in: &cancellables)
    }
}
