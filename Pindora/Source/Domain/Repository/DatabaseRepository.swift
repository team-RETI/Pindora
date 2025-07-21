//
//  DatabaseRepository.swift
//  Pindora
//
//  Created by 장주진 on 7/21/25.
//

import Foundation

public protocol DatabaseRepositoryProtocol {
    func create<T: Codable>(_ object: T, at collection: String, id: String, completion: @escaping (Result<Void, Error>) -> Void)
    func fetch<T: Codable>(from collection: String, id: String, as type: T.Type, completion: @escaping (Result<T, Error>) -> Void)
    func update<T: Codable>(_ object: T, at collection: String, id: String, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(from collection: String, id: String, completion: @escaping (Result<Void, Error>) -> Void)
}
