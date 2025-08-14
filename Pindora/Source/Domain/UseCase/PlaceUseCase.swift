//
//  PlaceUseCase.swift
//  Pindora
//
//  Created by 장주진 on 8/4/25.
//

import Foundation
import Combine

protocol PlaceUseCase {
    func fetchPlaces() -> AnyPublisher<[Place], Error>
}
