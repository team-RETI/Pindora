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
        let location: AnyPublisher<CLLocationCoordinate2D, Never>
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
        
        // 위치 스트림
        let location = locationUseCase.locationPublisher
            .map { $0.coordinate }
            .removeDuplicates { lhs, rhs in
                // 좌표 중복 판정(아주 미세한 이동은 무시)
                abs(lhs.latitude - rhs.latitude) < 0.0001 &&
                abs(lhs.longitude - rhs.longitude) < 0.0001
            }
            .handleEvents(receiveOutput: { loc in
                print("📌 location:", loc.latitude, loc.longitude)
            })
            .share()
            .eraseToAnyPublisher()
        
        // 검색 파이프라인:
        // 카테고리 선택 이벤트가 들어올 때마다 최신 좌표와 결합 → 유즈케이스 검색 → 결과 방출
        let placesRaw = selectedCategory
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
        
        // placesRaw: 검색으로 얻은 [Place] 스트림 (Failure == Never)
        // 최종: 이미지 URL이 주입된 [Place] 스트림
        let placeList: AnyPublisher<[Place], Never> = placesRaw
            // placesRaw에서 방출된 "장소 리스트"마다 하위 비동기 작업(여러 이미지 요청)을 붙여
            // 다시 [Place]로 만들어 방출하려고 flatMap 사용
            .flatMap { [weak self] places -> AnyPublisher<[Place], Never> in
                guard let self, !places.isEmpty else {
                    return Just([]).eraseToAnyPublisher()
                }

                // 과도한 API 호출 방지: 상위 10개만 이미지 검색
                // (필요에 따라 제한 제거/수정 가능)
                // indexed: [(index: Int, place: Place)]
                // 원래 순서를 복원하기 위해 인덱스를 함께 가지고있음
                let indexed = Array(places.prefix(10).enumerated())


                // 각 장소마다 "이미지 URL 1건 가져오기" 퍼블리셔를 만들고
                // (인덱스, 업데이트된 Place)를 방출하도록 맵핑
                let perPlacePublishers: [AnyPublisher<(Int, Place), Never>] = indexed.map { (idx, place) in
                    self.searchUseCase
                        .searchImage(query: place.placeName, display: 1, start: 1, sort: "sim", filter: "large")
                        // 성공 시 imageURL 주입
                        .map { url -> (Int, Place) in
                            var p = place
                            p.imageURL = url.first?.thumbnail ?? url.first?.link
                            return (idx, p) // 원래 순서 복원을 위해 idx 포함
                        }
                        // 실패해도 전체 스트림이 끊기지 않도록 실패한 항목만 nil
                        .catch { _ in
                            var p = place
                            p.imageURL = nil
                            return Just((idx, p))
                        }
                        .eraseToAnyPublisher()
                }

                // 여러 퍼블리셔를 병렬로 실행하고, 모든 결과가 모이면 한 번에 배열로 방출
                // Publishers.MergeMany():  병렬 실행
                return Publishers.MergeMany(perPlacePublishers)
                    .collect()
                    .map { pairs in
                        // pairs: [(index, Place)] — 응답 도착 순서는 뒤죽박죽일 수 있음
                        var result = places // 원본 리스트 복사(이미지 미조회 항목 포함)
                        // 인덱스 기준으로 정렬해 원래 순서에 맞는 위치에 덮어쓰기
                        for (idx, p) in pairs.sorted(by: { $0.0 < $1.0 }) {
                            result[idx] = p
                        }
                        print("✅ 최종 이미지 주입 완료:", result.count)
                        return result // 이미지 URL이 채워진 [Place]
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .share()
            .handleEvents(receiveOutput: { places in
                let filled = places.filter { $0.imageURL != nil }.count
                print("📤 placeList 방출: 총 \(places.count), imageURL 있음 \(filled)")
            })
            .eraseToAnyPublisher()
        
        return Output(
            location: location,
            selectedCategory: selectedCategory,
            places: placeList
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
