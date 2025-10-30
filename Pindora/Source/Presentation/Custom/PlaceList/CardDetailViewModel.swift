//
//  CardDetailViewModel.swift
//  Pindora
//
//  Created by eunchanKim on 7/29/25.
//

import UIKit
import Combine
import FirebaseAuth

final class CardDetailViewModel {
    // MARK: - Dependancy
    private var user: User?
    private let place: Place
    private let imageLoader: (URL) -> AnyPublisher<UIImage?, Never>
    private let placeUseCase: PlaceUseCase
    private let userUseCase: UserUseCaseProtocol
    private let imageUseCase: ImageUsecaseProtocol

    // Combine
    private var cancellables: Set<AnyCancellable> = []
    
    init(place: Place,
         imageLoader: @escaping (URL) -> AnyPublisher<UIImage?, Never> = CardDetailViewModel.defaultImageLoader,
         placeUseCase: PlaceUseCase,
         userUseCase: UserUseCaseProtocol,
         imageUseCase: ImageUsecaseProtocol
    ) {
        self.place = place
        self.imageLoader = imageLoader
        self.placeUseCase = placeUseCase
        self.userUseCase = userUseCase
        self.imageUseCase = imageUseCase
    }
    
    struct Input {
        /// viewDidLoad 시 한 번 호출
        let viewDidLoad: AnyPublisher<Void, Never>
        /// 즐겨찾기 버튼 탭 시 호출
        let addButtonTapped: AnyPublisher<Void, Never>
        /// 맵뷰 버튼 탭 시 호출
        let toMapButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        /// 장소에 대한 정보 출력
        let title: AnyPublisher<String, Never>
        let address: AnyPublisher<String, Never>
        let category: AnyPublisher<String, Never>
        let isSavedPlace: AnyPublisher<Bool, Never>
        let gallery: AnyPublisher<[UIImage?], Never>
    }
    
    func transform(input: Input) -> Output {
        // 고정 값들은 Just를 통해 즉시 1회 방출
        let title = Just(place.placeName).eraseToAnyPublisher()
        let address = Just(place.placeAddress).eraseToAnyPublisher()
        let category = Just(place.category).eraseToAnyPublisher()
        let gallery: AnyPublisher<[UIImage?], Never> = input.viewDidLoad
            .compactMap { [weak self] _ in self?.place.imageURLs }
            .flatMap { [weak self] urls -> AnyPublisher<[UIImage?], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }

                // http → https 교정 후 URL 배열로 변환
                let urlObjects = urls
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .compactMap { str -> URL? in
                        let secure = str.hasPrefix("http://")
                        ? str.replacingOccurrences(of: "http://", with: "https://")
                        : str
                        return URL(string: secure)
                    }

                // URL별 다운로드 퍼블리셔 생성
                let loaders = urlObjects.map { self.imageLoader($0) }
                return Publishers.MergeMany(loaders)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        input.viewDidLoad
            .flatMap { [weak self] _ -> AnyPublisher<Void, Never> in
                guard let self, let uid = Auth.auth().currentUser?.uid else {
                    return Just(()).eraseToAnyPublisher()
                }
                
                return self.userUseCase.fetchUser(uid: uid)
                    .flatMap { [weak self] user -> AnyPublisher<Void, UseCaseError> in
                        guard let self else {
                            return  Just(())
                                .setFailureType(to: UseCaseError.self)
                                .eraseToAnyPublisher()
                        }
                        // ✅ 저장 직전 최신 imageURLs를 주입해 전달
                               var updatedPlace = place
                               updatedPlace.imageURLs = self.place.imageURLs
                               if updatedPlace.imageURL == nil {
                                   updatedPlace.imageURL = self.place.imageURLs?.first
                               }
                               
                               return self.userUseCase.updateUserPlaceLog(user: user, place: updatedPlace)
                    }
                    .handleEvents(receiveOutput: { [weak self] in
                        guard let self else { return }
                        self.userUseCase.refreshIfNeeded(force: true, uid: uid)
                    })
                    .map { _ in }
                    .replaceError(with: ())
                    .eraseToAnyPublisher()
            }
            .sink { _ in }
            .store(in: &cancellables)
        
        input.addButtonTapped
            .flatMap { [weak self] _ -> AnyPublisher<Void, Never> in
                guard let self, let uid = Auth.auth().currentUser?.uid else {
                    return Just(()).eraseToAnyPublisher()
                }
                
                return self.userUseCase.fetchUser(uid: uid)
                    .flatMap { [weak self] user -> AnyPublisher<Void, UseCaseError> in
                        guard let self else {
                            return  Just(())
                                .setFailureType(to: UseCaseError.self)
                                .eraseToAnyPublisher()
                        }
                        var updatedPlace = place
                                  updatedPlace.imageURLs = self.place.imageURLs
                                  if updatedPlace.imageURL == nil {
                                      updatedPlace.imageURL = self.place.imageURLs?.first
                                  }
                                  
                                  return self.userUseCase.updateUserSavedPlaces(user: user, place: updatedPlace)
                    }
                    .handleEvents(receiveOutput: { [weak self] in
                        guard let self else { return }
                        self.userUseCase.refreshIfNeeded(force: true, uid: uid)
                    })
                    .map { _ in }
                    .replaceError(with: ())
                    .eraseToAnyPublisher()
            }
            .sink { _ in }
            .store(in: &cancellables)
        
        // 유저가 저장한 장소인지 아닌지 판단
        let isSavedPlaceStream =
        userUseCase.userPublisher
            .compactMap { $0?.savedPlaces }
            .map { places in
                places.contains(where: { $0.placeId == self.place.placeId })
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
        
        let isSavedPlace: AnyPublisher<Bool, Never> =
            input.addButtonTapped
                .map { _ in isSavedPlaceStream.prefix(1) } 
                .switchToLatest()
                .eraseToAnyPublisher()
        
        return Output(
            title: title,
            address: address,
            category: category,
            isSavedPlace: isSavedPlace,
            gallery: gallery
        )
    }
}

extension CardDetailViewModel {
    static func defaultImageLoader(_ url: URL) -> AnyPublisher<UIImage?, Never> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
