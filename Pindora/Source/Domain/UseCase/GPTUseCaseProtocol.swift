//
//  GPTUseCaseProtocol.swift
//  Pindora
//
//  Created by 장주진 on 9/2/25.
//

import Foundation
import Combine

protocol GPTUseCaseProtocol {
    func createPersonaNameAndDescription(from keyword: [String]) -> AnyPublisher<(name: String, description: String), Error>
}
