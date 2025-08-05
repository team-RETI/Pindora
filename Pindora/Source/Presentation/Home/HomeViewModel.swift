//  HomeViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine

final class HomeViewModel {
    @Published var places: [Place] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let placeUseCase: PlaceUseCase
    
    init(placeUseCase: PlaceUseCase) {
        self.placeUseCase = placeUseCase
    }
    
    func fetchPlaces() {
        placeUseCase.fetchPlaces()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("장소 로딩 실패: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] placeList in
                self?.places = placeList
            }.store(in: &cancellables)
    }
}
