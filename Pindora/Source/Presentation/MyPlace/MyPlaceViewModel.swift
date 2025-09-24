//  MyPlaceViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine

final class MyPlaceViewModel {
    // MARK: - Dependancy
    private let searchUseCase: SearchUseCaseProtocol
    private let placeUseCase: PlaceUseCase
    private let imageUseCase: ImageUsecaseProtocol
    // Combine
    private var cancellable: Set<AnyCancellable> = []
    
    init(
        searchUseCase: SearchUseCaseProtocol,
        placeUseCase: PlaceUseCase,
        imageUseCase: ImageUsecaseProtocol,
    ) {
        self.searchUseCase = searchUseCase
        self.placeUseCase = placeUseCase
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
        //        let places = input.viewDidLoad
        //            .flatMap { [weak self] _ -> AnyPublisher<[Place], Never> in
        //                guard let self else { return Just([]).eraseToAnyPublisher() }
        //                return self.placeUseCase.fetchPlaces()
        //                    .catch { error in
        //                        Just([] as [Place])
        //                    }
        //                    .eraseToAnyPublisher()
        //            }
        //            .share() // 여러 Subscriber가 있어도 1회만 수행
        //            .eraseToAnyPublisher()
        
        // ✅ 최초 1회 + 이후 reload 트리거마다 fetch
        let reloadStream = Publishers.Merge(
            input.viewDidLoad,
            input.reload
        )
            .handleEvents(receiveOutput: { _ in
                print("🔄 reload trigger")
            })
        
        reloadStream
            .sink { [weak self] _ in
                self?.placeUseCase.refreshIfNeeded(force: false)
            }
            .store(in: &cancellable)
        
        let places = placeUseCase.placesPublisher
            .removeDuplicates(by: { lhs, rhs in
                guard lhs.count == rhs.count else { return false }
                // ID 비교가 가장 안전/빠름
                return zip(lhs, rhs).allSatisfy { $0.placeId == $1.placeId }
            })
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { print("📦 places updated:", $0.count) })
            .eraseToAnyPublisher()
        
        // ✅ fetch → placesSubject 업데이트
        //        reloadStream
        //            .flatMap { [weak self] _ -> AnyPublisher<[Place], Never> in
        //                guard let self = self else { return Just([]).eraseToAnyPublisher() }
        //                return self.placeUseCase
        //                    .fetchPlaces()                  // AnyPublisher<[Place], Error>
        //                    .handleEvents(receiveSubscription: { _ in print("📥 fetchPlaces start") },
        //                                  receiveCompletion: { print("📥 fetchPlaces completion:", $0) })
        //                    .catch { err -> Just<[Place]> in
        //                        print("💥 fetchPlaces error:", err)
        //                        return Just([])
        //                    }
        //                    .eraseToAnyPublisher()
        //            }
        //            .sink { [weak self] places in
        //                print("📦 places updated:", places.count)
        //                self?.placesSubject.send(places)
        //            }
        //            .store(in: &cancellable)
        
        
        
        return Output(
            places: places
        )
    }
}
