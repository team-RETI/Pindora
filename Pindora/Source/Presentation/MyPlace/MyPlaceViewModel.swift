//  MyPlaceViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine
import FirebaseAuth

final class MyPlaceViewModel {
    // MARK: - Dependancy
    private let searchUseCase: SearchUseCaseProtocol
    private let placeUseCase: PlaceUseCase
    private let userUseCase: UserUseCaseProtocol
    private let imageUseCase: ImageUsecaseProtocol
    // Combine
    private var cancellable: Set<AnyCancellable> = []
    
    init(
        searchUseCase: SearchUseCaseProtocol,
        placeUseCase: PlaceUseCase,
        userUseCase: UserUseCaseProtocol,
        imageUseCase: ImageUsecaseProtocol,
    ) {
        self.searchUseCase = searchUseCase
        self.placeUseCase = placeUseCase
        self.userUseCase = userUseCase
        self.imageUseCase = imageUseCase
    }
    
    struct Input {
        /// viewDidLoad 시 한 번 호출
        let viewDidLoad: AnyPublisher<Void, Never>
        /// Add 버튼을 통한 수동적인 장소 저장
        let addPlace: AnyPublisher<String, Never>
        /// 화면 복귀/강제 새로고침 트리거 (VC의 reloadSubject 연결)
        let reload: AnyPublisher<Void, Never>
    }
    
    struct Output {
        /// DB에 저장된 장소 리스트
        let places: AnyPublisher<[Place], Never>
    }
    
    func transform(input: Input) -> Output {
        // 최초 1회 + 이후 reload 트리거마다 fetch
        let reloadStream = Publishers.Merge(
            input.viewDidLoad,
            input.reload
        )
            .handleEvents(receiveOutput: { _ in
                print("🔄 reload trigger")
            })
        
        reloadStream
            .sink { [weak self] _ in
                guard let uid = Auth.auth().currentUser?.uid else { return }
                self?.userUseCase.refreshIfNeeded(force: false, uid: uid)
            }
            .store(in: &cancellable)
        
        let places = userUseCase.savedPlacesPublisher
            .removeDuplicates(by: { lhs, rhs in
                guard lhs.count == rhs.count else { return false }
                // ID 비교가 가장 안전/빠름
                return zip(lhs, rhs).allSatisfy { $0.placeId == $1.placeId }
            })
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { print("📦 places updated:", $0.count) })
            .eraseToAnyPublisher()

        return Output(
            places: places
        )
    }
}
