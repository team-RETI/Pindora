//  HomeViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine
import CoreLocation
import FirebaseAuth

final class HomeViewModel {
    // MARK: - Dependancy
    // API/Framework
    private let locationUseCase: LocationUseCaseProtocol
    private let searchUseCase: SearchUseCaseProtocol
    // DB
    private let placeUseCase: PlaceUseCase
    private let userUseCase: UserUseCaseProtocol
    private let imageUseCase: ImageUsecaseProtocol
    private let userUseCase: UserUseCaseProtocol
    
    // Combine
    private var cancellable: Set<AnyCancellable> = []

    private let regionKeywords: [String] = [
        "서울", "부산", "대구", "인천", "광주", "대전", "울산", "세종",
        "경기", "경기도",
        "강원", "강원도",
        "충북", "충청북도",
        "충남", "충청남도",
        "전북", "전라북도",
        "전남", "전라남도",
        "경북", "경상북도",
        "경남", "경상남도",
        "제주", "제주도", "제주특별자치도"
    ]
    
    init(
        locationUseCase: LocationUseCaseProtocol,
        searchUseCase: SearchUseCaseProtocol,
        imageUseCase: ImageUsecaseProtocol,
        placeUseCase: PlaceUseCase,
        userUseCase: UserUseCaseProtocol
    ) {
        self.placeUseCase = placeUseCase
        self.locationUseCase = locationUseCase
        self.searchUseCase = searchUseCase
        self.imageUseCase = imageUseCase
        self.userUseCase = userUseCase
    }
    
    enum SearchTrigger {
        case category(String)
        case keyword(String)
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
        /// init시 고정 키워드 배열 한번 호출
        /// let fetchKeywords: AnyPublisher<Void, Never>
    }
    
    struct Output {
        /// 위치 퍼블리셔 노출
        let location: AnyPublisher<CLLocationCoordinate2D, Never>
        /// 선택된 카테고리 이름(뷰에서 선택 상태 갱신)
        let selectedCategory: AnyPublisher<String, Never>
        /// 유저가 저장한 장소인지 판단여부
        let savedPlace: AnyPublisher<Set<String>, Never>
        /// 검색 결과 장소리스트 (테이블 뷰 갱신)
        let places: AnyPublisher<[Place], Never>
        /// 고정 키워드 퍼블리셔
        let keywords: AnyPublisher<[String], Never>
    }
    
    func transform(input: Input) -> Output {
        let initialPlaces = PassthroughSubject<[Place], Never>()
        
        input.viewDidLoad
            .sink { [weak self] in
                guard let self = self else { return }
                self.locationUseCase.requestAuthorization()
                self.locationUseCase.startUpdatingLocation()
                
                // 유저 데이터 가져오기
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                self.userUseCase.fetchUser(uid: uid)
                    .catch { error -> Just<User> in
                        print("❌ 사용자 정보 불러오기 실패:", error)
                        return Just(User(userId: uid, likedPlaces: [], savedPlaces: [], visitedPlaces: []))
                    }
                    .flatMap { [weak self] user -> AnyPublisher<[Place], Never> in
                        guard let self else { return Just([]).eraseToAnyPublisher() }
                        
                        if user.selectedCategories.isEmpty {
                            print("⚠️ 유저 카테고리 없음")
                            return Just([]).eraseToAnyPublisher()
                        }
                        
                        // 카테고리별 2개 검색 → 병렬 실행
                        let publishers = user.selectedCategories.map { category in
                            self.searchUseCase
                                .search(keyword: category)              // AnyPublisher<[Place], UseCaseError>
                                .map { Array($0.prefix(2)) }
                                .catch { _ in Just([]) }
                                .eraseToAnyPublisher()
                        }
                        
                        return Publishers.MergeMany(publishers)
                            .collect()
                            .map { $0.flatMap { $0 } } // [[Place]] → [Place]
                            .eraseToAnyPublisher()
                    }
                    .sink { places in
                        print("✨ 초기 places 방출: \(places.count)개")
                        initialPlaces.send(places)
                    }
                    .store(in: &self.cancellable)
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
            .eraseToAnyPublisher()
        
        let trigger: AnyPublisher<SearchTrigger, Never> =
        Publishers.Merge(
            selectedCategory.map(SearchTrigger.category),
            keywordNormalized.map(SearchTrigger.keyword)
        )
        .eraseToAnyPublisher()
        
        let placesRaw: AnyPublisher<[Place], Never> =
            trigger
                .combineLatest(location)
                .map { [weak self] (trig, center) -> AnyPublisher<[Place], Never> in
                    guard let self else { return Just([]).eraseToAnyPublisher() }
                    switch trig {
                    case .category(let cat):
                        // 내 주변 검색 (center 사용)
                        return self.searchUseCase
                            .search(keyword: cat, center: center)
                            .catch { _ in Just([]) }
                            .eraseToAnyPublisher()

                    case .keyword(let kw):
                        // 전역 검색
                        return self.searchUseCase
                            .search(keyword: kw)
                            .catch { _ in Just([]) }
                            .eraseToAnyPublisher()
                    }
                }
                .switchToLatest()
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveOutput: { print("📦 placesRaw:", $0.count) })
                .eraseToAnyPublisher()
        
        // 유저가 저장한 장소인지 아닌지 판단
        let savedPlace: AnyPublisher<Set<String>, Never> =
        userUseCase.userPublisher
            .compactMap { $0?.savedPlaces }
            .map { Set($0.map { $0.placeId }) }
            .removeDuplicates()
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
            .map { places in
                // 중복 제거: placeId 기준
                var seen = Set<String>()
                return places.filter { seen.insert($0.placeId).inserted }
            }
            .receive(on: DispatchQueue.main)
            .share()
            .handleEvents(receiveOutput: { places in
                let filled = places.filter { $0.imageURL != nil }.count
                print("📤 placeList 방출: 총 \(places.count), imageURL 있음 \(filled)")
            })
            .eraseToAnyPublisher()
        
        // fetchKeywords는 View에서 트리거할 이벤트가 아니므로 Output에만 존재합니다.
        let keywords = placeUseCase.fetchKeywords()
            .catch { _ in Just([]) }
            .share()
            .eraseToAnyPublisher()
        
        /// 이미지 검색 후 ImageUseCase 이용하여 저장
        /// 장소 추합된 이후 PlaceUseCase 이용하여 저장
        return Output(
            location: location,
            selectedCategory: selectedCategory,
            savedPlace: savedPlace,
            places: placeList
        )
    }
}

// MARK: - 키워드 관련 로직
extension HomeViewModel {
    func fetchKeywords() {
        placeUseCase.fetchKeywords()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("키워드 로딩 실패: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] keywordList in
                self?.keywords = keywordList
            }.store(in: &cancellable)
    }
    
    func filterKeywords(query: String) {
        if query.isEmpty {
            filteredKeywords = []
        } else {
            filteredKeywords = keywords.filter {
                /// localizedCaseInsensitiveContains: 대소문자 무시, 로케일 고려, 부분문자열 검색 가능
                $0.localizedStandardContains(query)
            }
        }
    }
    
    func resetFilter() {
        filteredKeywords = []
    }
}
