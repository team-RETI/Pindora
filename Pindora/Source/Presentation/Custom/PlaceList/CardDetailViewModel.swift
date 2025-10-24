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
    // private let hashtagBuilder: (Place) -> String
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
        //self.hashtagBuilder = hasthtagBuilder
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
        let mainImage: AnyPublisher<UIImage?, Never>
        let category: AnyPublisher<String, Never>
        let isSavedPlace: AnyPublisher<Bool, Never>
    }
    
    func transform(input: Input) -> Output {
        // 고정 값들은 Just를 통해 즉시 1회 방출
        let title = Just(place.placeName).eraseToAnyPublisher()
        let address = Just(place.placeAddress).eraseToAnyPublisher()
        let category = Just(place.category).eraseToAnyPublisher()
        
        // 이미지: viewDidAppear 트리거에 반응해 1회 로드
        let mainImage: AnyPublisher<UIImage?, Never> = input.viewDidLoad
            .map { [weak self] _ -> URL? in
                guard
                    let self,
                    let raw = self.place.imageURL?.trimmingCharacters(in: .whitespacesAndNewlines),
                    raw.isEmpty == false
                else { return nil }

                // ATS 대비 http -> https 치환
                let secure = raw.hasPrefix("http://")
                ? raw.replacingOccurrences(of: "http://", with: "https://")
                : raw
                return URL(string: secure)
            }
            .flatMap { [weak self] url -> AnyPublisher<UIImage?, Never> in
                guard let self, let url else {
                    return Just<UIImage?>(nil).eraseToAnyPublisher()
                }
                return self.imageLoader(url)
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
                        return self.userUseCase.updateUserPlaceLog(user: user, place: place)
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
                        return self.userUseCase.updateUserSavedPlaces(user: user, place: place)
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
        
        // 장소 위치를 보기위한 맵뷰 호출
//        input.toMapButtonTapped
//        place.
        print(place)
        
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
            mainImage: mainImage,
            category: category,
            isSavedPlace: isSavedPlace
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
