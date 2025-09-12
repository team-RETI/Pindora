//  HomeViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine
import CoreLocation

final class HomeViewModel {
    // MARK: - Dependancy
    // API/Framework
    private let locationUseCase: LocationUseCaseProtocol
    private let searchUseCase: SearchUseCaseProtocol
    // DB
    private let placeUseCase: PlaceUseCase
    private let imageUseCase: ImageUsecaseProtocol
    // Combine
    private var cancellable: Set<AnyCancellable> = []
    
    
    init(
        locationUseCase: LocationUseCaseProtocol,
        searchUseCase: SearchUseCaseProtocol,
        imageUseCase: ImageUsecaseProtocol,
        placeUseCase: PlaceUseCase,
    ) {
        self.placeUseCase = placeUseCase
        self.locationUseCase = locationUseCase
        self.searchUseCase = searchUseCase
        self.imageUseCase = imageUseCase
    }
    
    struct Input {
        /// viewDidLoad 시 한 번 호출
        let viewDidLoad: AnyPublisher<Void, Never>
        /// 서치바 에서 키워드 입력
        let keyword: AnyPublisher<String, Never>
        /// 위치권한 요청 트리거 -> alert을 이용한 위치 요청
        let mapCenter: AnyPublisher<CLLocationCoordinate2D, Never>
        /// 카테고리 버튼이 선택될 때 선택된 태그(이름) 스트림
        let categorySelected: AnyPublisher<String, Never>
    }
    
    struct Output {
        /// 위치 퍼블리셔 노출
        let location: AnyPublisher<CLLocationCoordinate2D, Never>
        /// 선택된 카테고리 이름(뷰에서 선택 상태 갱신)
        let selectedCategory: AnyPublisher<String, Never>
        /// 검색 결과 장소리스트 (테이블 뷰 갱신)
        let places: AnyPublisher<[Place], Never>
    }
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .sink { [weak self] in
                guard let self = self else { return }
                self.locationUseCase.requestAuthorization()
                self.locationUseCase.startUpdatingLocation()
            }
            .store(in: &cancellable)
        
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
        
        // 선택된 카테고리 이름은 UI 선택 상태 갱신에도 쓰일 수 있도록 그대로 Output
        let selectedCategory = input.categorySelected
            .removeDuplicates()
            .handleEvents(receiveOutput: { cat in
                print("🏷️ selectedCategory:", cat)
            })
            .share()
            .eraseToAnyPublisher()
        
        // 검색 쿼리: 키워드 입력 or 카테고리 선택을 하나의 "키워드"로 통합
        // (우선순위는 동일: 둘중 어떤 이벤트가 와도 검색 트리거
        let keywordNormalized = input.keyword
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .handleEvents(receiveOutput: { kw in
                print("⌨️ keywordNormalized:", kw)
            })
        
        // Publishers.Merge(A, B): 두 퍼블리셔의 이벤트를 시간순으로 그대로 섞어 하나의 퍼블리셔로 합침
        // removeDuplicates(): 연속된 동일 값은 한번만 통과시킴
        let searchQuery = Publishers.Merge(keywordNormalized, selectedCategory)
            .removeDuplicates()
            .handleEvents(receiveOutput: { q in
                print("🔎 searchQuery:", q)
            })
            .eraseToAnyPublisher()
        
        // 검색 스트림
        // 검색 실패 시 UI 안정성을 위해 빈 배열로 대체
        let placesRaw: AnyPublisher<[Place], Never> = searchQuery
            // 검색어가 나올 때의 최신 center를 묶어서 사용
            .combineLatest(location)                         // -> (query: String, center: CLLocationCoordinate2D)
            // 최신 요청만 유지
            .map { [weak self] (query, location) -> AnyPublisher<[Place], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.searchUseCase
                    .search(keyword: query, center: location) // ✅ 변경 포인트
                    .handleEvents(receiveOutput: { places in
                        print("📥 search 결과 개수:", places.count)
                    })
                    .catch { _ in Just([]) }               // 실패 시 빈 배열로 대체
                    .eraseToAnyPublisher()
            }
            .switchToLatest()                               // 최신 검색만 유지(이전 요청 자동 취소)
            .handleEvents(receiveOutput: { places in
                print("📦 placesRaw 방출:", places.count)
            })
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
                            p.imageURL = url.first?.link ?? url.first?.thumbnail
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
        
        // 저장: Place.imageURL이 있는 경우만 이미지 파일로 변환 후 업로드
        // imageUseCase: 이미지 파일을 업로드
        // placeUseCase: 장소에 대한 정보를 저장
//        placeList
//            .flatMap { [weak self] places -> AnyPublisher<[URL], Never> in
//                guard let self else { return Just([]).eraseToAnyPublisher() }
//
//                // 업로드 요청을 담을 퍼블리셔 배열
//                let uploadPublishers: [AnyPublisher<URL, Never>] = places.compactMap { place in
//                    guard
//                        let urlString = place.imageURL,
//                        let url = URL(string: urlString)
//                    else {
//                        return nil // 이미지 URL이 없는 경우 스킵
//                    }
//
//                    // 1) 네트워크에서 UIImage 다운로드
//                    return URLSession.shared.dataTaskPublisher(for: url)
//                        .mapError { $0 as Error }                    // URLError -> Error
//                        .compactMap { UIImage(data: $0.data) }       // Data -> UIImage
//                        .flatMap { image in
//                            // 2) 변환된 UIImage를 DB 업로드
//                            self.imageUseCase.upload(
//                                image: image,
//                                folder: "PlaceImage",                       // 원하는 폴더명
//                                fileName: "\(place.placeName).jpg"        // 고유 파일명
//                            )
//                        }
//                        .catch { error in
//                            print("❌ 이미지 업로드 실패:", error.caseName)
//                            return Empty<URL, Never>() // 실패 시 이 이미지 스킵
//                        }
//                        .eraseToAnyPublisher()
//                }
//
//                // 여러 업로드를 병렬 실행 후, 완료된 URL들을 [URL]로 모음
//                return Publishers.MergeMany(uploadPublishers)
//                    .collect()
//                    .eraseToAnyPublisher()
//            }
//            .sink { uploadedURLs in
//                // ✅ 업로드 성공한 이미지 URL 배열
////                print("📸 업로드 완료된 이미지 개수:", uploadedURLs.count)
//                // 필요하다면 여기서 DB에 URL 참조를 저장하거나, place 객체 갱신 가능
//            }
//            .store(in: &cancellable)
        
        /// 이미지 검색 후 ImageUseCase 이용하여 저장
        /// 장소 추합된 이후 PlaceUseCase 이용하여 저장
        return Output(
            location: location,
            selectedCategory: selectedCategory,
            places: placeList
        )
    }
    
    
    
    // 🧑‍🔧Input-Output 형식으로 바꾸겠습니다~
    //    func fetchPlaces() {
    //        placeUseCase.fetchPlaces()
    //            .receive(on: DispatchQueue.main)
    //            .sink { completion in
    //                if case let .failure(error) = completion {
    //                    print("장소 로딩 실패: \(error.localizedDescription)")
    //                }
    //            } receiveValue: { [weak self] placeList in
    //                self?.places = placeList
    //            }.store(in: &cancellables)
    //    }
}
