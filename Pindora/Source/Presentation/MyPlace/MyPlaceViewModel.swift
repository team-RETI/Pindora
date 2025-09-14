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
    }
    
    struct Output {
        /// DB에 저장된 장소 리스트
        let places: AnyPublisher<[Place], Never>
    }
    
    func transform(input: Input) -> Output {
        let places = input.viewDidLoad
            .flatMap { [weak self] _ -> AnyPublisher<[Place], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                return self.placeUseCase.fetchPlaces()
                    .catch { error in
                        Just([] as [Place])
                    }
                    .eraseToAnyPublisher()
            }
            .share() // 여러 Subscriber가 있어도 1회만 수행
            .eraseToAnyPublisher()
        
        return Output(places: places)
    }
}
