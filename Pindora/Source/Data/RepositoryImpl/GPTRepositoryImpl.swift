//
//  GPTRepositoryImpl.swift
//  Pindora
//
//  Created by 장주진 on 9/2/25.
//

import Foundation
import Combine

final class GPTRepositoryImpl: GPTRepositoryProtocol {
    private let apiManager = GPTAPIManager()

    func generateDescription(for input: String) -> AnyPublisher<String, Error> {
        apiManager.sendPrompt(input)
    }
}
