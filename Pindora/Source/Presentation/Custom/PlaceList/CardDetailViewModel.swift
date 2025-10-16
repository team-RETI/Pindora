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
    private let userUsecase: UserUseCaseProtocol
    private let imageUseCase: ImageUsecaseProtocol

    // Combine
    private var cancellables: Set<AnyCancellable> = []
    
    init(place: Place,
         imageLoader: @escaping (URL) -> AnyPublisher<UIImage?, Never> = CardDetailViewModel.defaultImageLoader,
         placeUseCase: PlaceUseCase,
         userUsecase: UserUseCaseProtocol,
         imageUseCase: ImageUsecaseProtocol
    ) {
        self.place = place
        self.imageLoader = imageLoader
        //self.hashtagBuilder = hasthtagBuilder
        self.placeUseCase = placeUseCase
        self.userUsecase = userUsecase
        self.imageUseCase = imageUseCase
    }
    
    struct Input {
        /// viewDidLoad 시 한 번 호출
        let viewDidLoad: AnyPublisher<Void, Never>
        /// 즐겨찾기 버튼 탭 시 호출
        let addButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        /// 장소에 대한 정보 출력
        let title: AnyPublisher<String, Never>
        let address: AnyPublisher<String, Never>
        let likeCount: AnyPublisher<String?, Never>
        let mainImage: AnyPublisher<UIImage?, Never>
        let category: AnyPublisher<String, Never>
        // let hashtag: AnyPublisher<String, Never>
        // let tagName: AnyPublisher<String, Never>
    }
    
    func transform(input: Input) -> Output {
        // 고정 값들은 Just를 통해 즉시 1회 방출
        let title = Just(place.placeName).eraseToAnyPublisher()
        let address = Just(place.placeAddress).eraseToAnyPublisher()
        let category = Just(place.category).eraseToAnyPublisher()
        let likedCount = Just(place.likedCount?.description).eraseToAnyPublisher()
        //let hashtags = Just(hashtagBuilder(place)).eraseToAnyPublisher()
        
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
                
                return self.userUsecase.fetchUser(uid: uid)
                    .flatMap { [weak self] user -> AnyPublisher<Void, UseCaseError> in
                        guard let self else {
                            return  Just(())
                                .setFailureType(to: UseCaseError.self)
                                .eraseToAnyPublisher()
                        }
                        return self.userUsecase.updateUserPlaceLog(user: user, place: place)
                    }
                    .handleEvents(receiveOutput: { [weak self] in
                        guard let self else { return }
                        self.placeUseCase.refreshIfNeeded(force: true)
                        self.userUsecase.refreshIfNeeded(force: true, uid: uid)
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
                
                return self.userUsecase.fetchUser(uid: uid)
                    .flatMap { [weak self] user -> AnyPublisher<Void, UseCaseError> in
                        guard let self else {
                            return  Just(())
                                .setFailureType(to: UseCaseError.self)
                                .eraseToAnyPublisher()
                        }
                        return self.userUsecase.updateUserSavedPlaces(user: user, place: place)
                    }
                    .handleEvents(receiveOutput: { [weak self] in
                        guard let self else { return }
                        self.placeUseCase.refreshIfNeeded(force: true)
                        self.userUsecase.refreshIfNeeded(force: true, uid: uid)
                    })
                    .map { _ in }
                    .replaceError(with: ())
                    .eraseToAnyPublisher()
            }
            .sink { _ in }
            .store(in: &cancellables)
        
        return Output(
            title: title,
            address: address,
            likeCount: likedCount,
            mainImage: mainImage,
            category: category,
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

    static func defaultHashtagBuilder(_ place: Place) -> String {
        let keywords: [String] = [place.placeName, place.category ?? ""].filter { !$0.isEmpty }
        return keywords.map { "#\($0)" }.joined(separator: " ")
    }
}
