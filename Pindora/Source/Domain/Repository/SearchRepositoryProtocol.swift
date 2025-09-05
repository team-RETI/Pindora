//
//  SearchRepositoryProtocol.swift
//  Pindora
//
//  Created by eunchanKim on 9/4/25.
//

import Foundation
import Combine

protocol SearchRepositoryProtocol {
    func search(keyword: String) -> AnyPublisher<[Place], InfraError>
}
