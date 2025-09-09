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
    private let searchUseCase: SearchUseCaseProtocol
    private var cancellable: Set<AnyCancellable> = []
    
    // MARK: - Init
    init(locationUseCase: LocationUseCaseProtocol, searchUseCase: SearchUseCaseProtocol) {
        self.locationUseCase = locationUseCase
        self.searchUseCase = searchUseCase
    }
    
    struct Input {
        /// viewDidLoad 시 한 번만 보냄
        let viewDidLoad: AnyPublisher<Void, Never>
        /// 현재위치 버튼이 눌리면 사용자 현재 좌표 스트림
        let mapCenter: AnyPublisher<CLLocationCoordinate2D, Never>
        /// 위치권한 요청 트리거
        let locationButtonTapped: AnyPublisher<Void, Never>
        /// 카테고리 버튼이 선택될 때 선택된 태그(이름) 스트림
        let categorySelected: AnyPublisher<String, Never>
    }

    struct Output {
        /// 위치 퍼블리셔 그대로 노출
        let location: AnyPublisher<CLLocation, Never>
        /// 선택된 카테고리 이름(뷰에서 선택 상태에 갱신)
        let selectedCategory: AnyPublisher<String, Never>
        /// 검색 결과 장소 리스트(맵 랜더링에 사용)
        let places: AnyPublisher<[Place], Never>
    }

    func transform(input: Input) -> Output {
        // viewDidLoad 시 딱 한번 권한 + 위치 요청(업데이트 X)
        input.viewDidLoad
            .sink { [weak self] in
                self?.locationUseCase.requestAuthorization()
                self?.locationUseCase.startUpdatingLocation()
                self?.locationUseCase.stopUpdatingLocation()
            }
            .store(in: &cancellable)
        
        // input을 받았을 때: 권한 요청 + 위치 업데이트 시작
        input.locationButtonTapped
            .sink { [weak self] in
                self?.locationUseCase.requestAuthorization()
                self?.locationUseCase.startUpdatingLocation()
                self?.locationUseCase.stopUpdatingLocation()
            }
            .store(in: &cancellable)
        
        // 최신 카테고리와 최신 지도 중심 좌표를 결합하여 검색
        let sharedCenter = input.mapCenter
            .removeDuplicates { lhs, rhs in
                // 좌표 중복 판정(아주 미세한 이동은 무시)
                abs(lhs.latitude - rhs.latitude) < 0.0001 &&
                abs(lhs.longitude - rhs.longitude) < 0.0001
            }
            .share()
            .eraseToAnyPublisher()
        
        /// 선택된 카테고리 이름은 UI 선택 상태 갱신에도 쓰일 수 있도록 그대로 Output
        let selectedCategory = input.categorySelected
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
        
        // 검색 파이프라인:
        // 카테고리 선택 이벤트가 들어올 때마다 최신 좌표와 결합 → 유즈케이스 검색 → 결과 방출
        let searchTrigger = selectedCategory
            .withLatestFrom(sharedCenter) // 아래 유틸 참고
            .flatMap { [weak self] (category, center) -> AnyPublisher<[Place], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                return self.searchUseCase
                    .search(keyword: category, center: center)
                    .handleEvents(receiveSubscription: { _ in /* 로딩 인디케이터 on */ },
                                  receiveCompletion: { _ in /* 로딩 인디케이터 off */ })
                    .catch { _ in Just([]) } // 실패 시 UI 안정성 위해 빈 배열
                    .eraseToAnyPublisher()
            }
            .share()
            .eraseToAnyPublisher()
        
        return Output(
            location: locationUseCase.locationPublisher,
            selectedCategory: selectedCategory,
            places: searchTrigger
        )
    }
}

// MARK: - Small Combine helper
private extension Publisher {
    /// Rx의 withLatestFrom 유사 유틸
    func withLatestFrom<Other: Publisher>(_ other: Other)
    -> AnyPublisher<(Output, Other.Output), Failure> where Other.Failure == Failure {
        self.combineLatest(other).map { ($0.0, $0.1) }.eraseToAnyPublisher()
    }
}
