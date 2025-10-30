//  HomeViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine
import CoreLocation
import FirebaseAuth


enum SortOption {
    case distance
    case like
}

final class HomeViewModel {
    // MARK: - Dependancy
    // API/Framework
    private let locationUseCase: LocationUseCaseProtocol
    private let searchUseCase: SearchUseCaseProtocol
    // DB
    private let placeUseCase: PlaceUseCase
    private let userUseCase: UserUseCaseProtocol
    private let imageUseCase: ImageUsecaseProtocol
    
    // Combine
    private var cancellable: Set<AnyCancellable> = []

    @Published var keywords: [String] = []
    @Published var filteredKeywords: [String] = []
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
    
    // 정렬 상태를 저장 및 방출하는 퍼블리셔
    let sortOptionSubject = CurrentValueSubject<SortOption, Never>(.distance)
    
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
        /// 정렬 버튼 탭 이벤트
        let sortButtonTapped: AnyPublisher<Void, Never>
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
        
        let maxImages = 5
        let placeList: AnyPublisher<[Place], Never> = Publishers.Merge(initialPlaces, placesRaw)
            .flatMap { [weak self] places -> AnyPublisher<[Place], Never> in
                guard let self, !places.isEmpty else {
                    return Just([]).eraseToAnyPublisher()
                }

                // 과도 호출 방지: 상위 10개만 이미지 조회 (필요시 조정)
                let indexed = Array(places.prefix(10).enumerated())

                let perPlacePublishers: [AnyPublisher<(Int, Place), Never>] = indexed.map { (idx, place) in
                    self.searchUseCase
                        .searchImage(
                            query: place.placeName,
                            display: maxImages,       // ✅ N장 요청
                            start: 1,
                            sort: "sim",
                            filter: "large"
                        )
                        .map { results -> (Int, Place) in
                            var p = place
                            // 결과에서 URL 추출(link 우선, 없으면 thumbnail)
                            let urls = results
                                .compactMap { $0.link }
                                .filter { !$0.isEmpty }
                                .prefix(maxImages)

                            p.imageURLs = Array(urls)          // ✅ 여러 장 주입
                            if p.imageURL == nil {             // ✅ 호환성: 첫 장을 단일 필드에도
                                p.imageURL = p.imageURLs?.first
                            }
                            return (idx, p)
                        }
                        .catch { _ in
                            var p = place
                            p.imageURLs = []                   // 실패해도 스트림 유지
                            // p.imageURL는 기존 값 유지 (없으면 nil)
                            return Just((idx, p))
                        }
                        .eraseToAnyPublisher()
                }

                return Publishers.MergeMany(perPlacePublishers)
                    .collect()
                    .map { pairs in
                        var result = places
                        for (idx, p) in pairs.sorted(by: { $0.0 < $1.0 }) {
                            result[idx] = p
                        }
                        print("✅ 이미지 주입 완료 (max \(maxImages)장):", result.count)
                        return result
                    }
                    .eraseToAnyPublisher()
            }
            .map { places in
                // ✅ placeId 기준 중복 제거
                var seen = Set<String>()
                return places.filter { seen.insert($0.placeId).inserted }
            }
            .receive(on: DispatchQueue.main)
            .share()
            .handleEvents(receiveOutput: { places in
                // ✅ nil-safe count
                let withImagesCount = places.filter { ($0.imageURLs?.isEmpty == false) }.count
                print("📤 placeList 방출: 총 \(places.count), imageURLs 채워진 항목 \(withImagesCount)")
            })
            .eraseToAnyPublisher()
        
        // 정렬 옵션 토글
        input.sortButtonTapped
            .sink { [weak self] in
                guard let self = self else { return }
                let newOption: SortOption = (self.sortOptionSubject.value == .distance) ? .like : .distance
                self.sortOptionSubject.send(newOption)
            }
            .store(in: &cancellable)
        
        // 정렬 적용
        let sortedPlaces = placeList
            .combineLatest(location, sortOptionSubject)
            .map { places, currentLocation, SortOption -> [Place] in
                switch SortOption {
                case .distance:
                    return places.sorted {
                        $0.distance(from: currentLocation) < $1.distance(from: currentLocation)
                    }
                case .like:
                    return places.sorted {
                        ($0.likedCount ?? 0) > ($1.likedCount ?? 0)
                    }
                }
            }.eraseToAnyPublisher()
        
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
            places: sortedPlaces,
            keywords: keywords
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
