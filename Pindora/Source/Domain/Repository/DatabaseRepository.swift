//
//  DatabaseRepository.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation
import Combine

public protocol DatabaseRepositoryProtocol {
    func create<T: Codable>(_ object: T, at collection: String, id: String) -> AnyPublisher<Void, Error>
    func fetch<T: Codable>(from collection: String, id: String, as type: T.Type) -> AnyPublisher<T, Error>
    func update<T: Codable>(_ object: T, at collection: String, id: String) -> AnyPublisher<Void, Error>
    func delete(from collection: String, id: String) -> AnyPublisher<Void, Error>
}
