//
//  GPTRepositoryProtocol.swift
//  Pindora
//
//  Created by 장주진 on 9/2/25.
//

import Foundation
import Combine

protocol GPTRepositoryProtocol {
    func generateDescription(for input: String) -> AnyPublisher<String, Error>
}
