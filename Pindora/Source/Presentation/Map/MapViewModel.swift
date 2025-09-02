//  MapViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine
import CoreLocation

final class MapViewModel {
    
    // MARK: - Dependency
    private let locationUseCase: LocationUseCaseProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Init
    init(locationUseCase: LocationUseCaseProtocol) {
        self.locationUseCase = locationUseCase
    }

    struct Input {
        let requestPermissionTapped: AnyPublisher<Void, Never>
    }

    struct Output {
        let location: AnyPublisher<CLLocation, Never>
    }

    func transform(input: Input) -> Output {
        // input을 받았을 때: 권한 요청 + 위치 업데이트 시작
        input.requestPermissionTapped
            .sink { [weak self] in
                self?.locationUseCase.requestAuthorization()
                self?.locationUseCase.startUpdatingLocation()
            }
            .store(in: &cancellables)

        return Output(
            location: locationUseCase.locationPublisher
        )
    }
}
