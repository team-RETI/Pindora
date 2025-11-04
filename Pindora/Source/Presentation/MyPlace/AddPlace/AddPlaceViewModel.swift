//
//  AddPlaceViewModel.swift
//  Pindora
//
//  Created by eunchanKim on 7/28/25.
//

import UIKit
import Combine
import CoreLocation
import FirebaseAuth

final class AddPlaceViewModel {
    // MARK: - Dependancy
    // API/Framework
    private let searchUseCase: SearchUseCaseProtocol
    // DB
    private let placeUseCase: PlaceUseCase
    private let userUseCase: UserUseCaseProtocol
    private let imageUseCase: ImageUsecaseProtocol
    // Combine
    private var cancellable: Set<AnyCancellable> = []
    
    var user: User?
    var errorMessage: String?
    private let latestPlace = CurrentValueSubject<Place?, Never>(nil)
    let latestCategory = CurrentValueSubject<String?, Never>(nil)
    
    init(
        searchUseCase: SearchUseCaseProtocol,
        placeUseCase: PlaceUseCase,
        userUseCase: UserUseCaseProtocol,
        imageUseCase: ImageUsecaseProtocol
    ) {
        self.searchUseCase = searchUseCase
        self.placeUseCase = placeUseCase
        self.userUseCase = userUseCase
        self.imageUseCase = imageUseCase
        
        loadUser()
    }
    
    struct Input {
        let keyword: AnyPublisher<String, Never>
        let categorySelected: AnyPublisher<String, Never>
        let confirmButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let selectedCategory: AnyPublisher<String, Never>
        let place: AnyPublisher<Place, Never>
        let saveResult: AnyPublisher<Result<Void, Error>, Never>
    }
    
    func injectPlace(_ place: Place) {
        latestPlace.send(place)
        print("✅ injectPlace 실행됨. latestPlace 업데이트:\n\(place.description)")
    }
    
    func transform(input: Input) -> Output {
        
        // 1) 키워드 정리
        let keywordNormalized = input.keyword
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .handleEvents(receiveOutput: { kw in
                print("⌨️ keywordNormalized:", kw)
            })
            .eraseToAnyPublisher()
        
        // 2) 선택 카테고리 스트림 (필요 시 share 가능)
        let selectedCategory = input.categorySelected
            .removeDuplicates()
            .handleEvents(receiveOutput: { cat in
                print("🏷️ selectedCategory:", cat)
            })
            .share()
            .eraseToAnyPublisher()
        
        // 3) 검색 스트림: 최신 검색만 유지 + 실패 시 빈값
        let place: AnyPublisher<Place, Never> = keywordNormalized
            .map { [weak self] query -> AnyPublisher<Place, Never> in
                guard let self = self else {
                    return Empty<Place, Never>().eraseToAnyPublisher()
                }
                return self.searchUseCase
                    .searchGeocode(query: query, page: 1, size: 1) // -> AnyPublisher<Place, Error>
                    .handleEvents(receiveOutput: { place in
                        print("📍 place:", place)
                    })
                    .catch { _ in Empty<Place, Never>() } // 에러 시 무시
                    .eraseToAnyPublisher()
            }
            .switchToLatest()                  // 이전 요청 자동 취소
            .receive(on: DispatchQueue.main)   // UI 업데이트
            .eraseToAnyPublisher()
        
        // 4) 최신 Place를 저장해 두기 (withLatestFrom 대용)
        place
            .sink { [weak self] in self?.latestPlace.send($0) }
            .store(in: &cancellable)
        
        // 4-1) 최신 Category도 저장해 두기
        selectedCategory
            .sink { [weak self] in self?.latestCategory.send($0) }
            .store(in: &cancellable)
        
        // 4-2) 저장을 할 수 있는 상황인지 알림
        // 저장 트리거를 케이스로 분기
        enum SaveTrigger {
            case missingPlace
            case missingCategory
            case ready(Place, String)
        }
        
        // 5) 확인 버튼 탭 → 최신 Place 저장
        let trigger = input.confirmButtonTapped
            .map { [weak self] _ -> SaveTrigger in
                guard let self else { return .missingPlace }
                let p = self.latestPlace.value
                let c = self.latestCategory.value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if p == nil { return .missingPlace }
                if c.isEmpty { return .missingCategory }
                return .ready(p!, c)
            }
            .eraseToAnyPublisher()
        
        let saveResultSubject = PassthroughSubject<Result<Void, Error>, Never>()
        
        trigger
            .flatMap { [weak self] t -> AnyPublisher<Result<Void, Error>, Never> in
                guard let self = self else { return Just(.failure(SaveError.backend(NSError(domain: "deinit", code: -1)))).eraseToAnyPublisher() }
                guard let user = self.user else { return Just(.failure(SaveError.backend(NSError(domain: "deinit", code: -1)))).eraseToAnyPublisher()}
                
                switch t {
                case .missingPlace:
                    return Just(.failure(SaveError.missingPlace)).eraseToAnyPublisher()
                    
                case .missingCategory:
                    return Just(.failure(SaveError.missingCategory)).eraseToAnyPublisher()
                    
                case .ready(var place, let category):
                    place = place.withCategory(category)
                    print("💾 try save:", place)
                    
                    return self.userUseCase
                        .updateUserSavedPlaces(user: user, place: place)
                        .handleEvents(receiveOutput: { [weak self] in
                            self?.userUseCase.refreshIfNeeded(force: true, uid: user.userId) // 🔔 리스트 즉시 업데이트
                        })
                        .map { .success(()) }
                        .catch { Just(.failure(SaveError.backend($0))) }
                        .eraseToAnyPublisher()
                }
            }
            .subscribe(saveResultSubject)
            .store(in: &cancellable)
        
        return Output(
            selectedCategory: selectedCategory,
            place: place,
            saveResult: saveResultSubject.eraseToAnyPublisher()
        )
    }
    
    func loadUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "로그인된 사용자가 없습니다."
            return
        }
        
        userUseCase.fetchUser(uid: uid)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = "사용자 정보를 불러오지 못함: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] user in
                print("유저 데이터: \(user)") //가져오는 데이터 확인용 나중에 삭제할 예정
                self?.user = user
            }
            .store(in: &cancellable)
    }
}

enum SaveError: LocalizedError {
    case missingPlace
    case missingCategory
    case backend(Error)
    
    var errorDescription: String? {
        switch self {
        case .missingPlace:    return "주소(장소) 정보가 없어요. 주소를 먼저 입력해 주세요."
        case .missingCategory: return "카테고리를 선택해 주세요."
        case .backend(let e):  return e.localizedDescription
        }
    }
}
