//
//  DatabaseRepositoryImpl.swift
//  Pindora
//
//  Created by 장주진 on 7/21/25.
//

import Foundation

final class DatabaseRepositoryImpl: DatabaseRepositoryProtocol {
    func create<T>(_ object: T, at collection: String, id: String, completion: @escaping (Result<Void, any Error>) -> Void) where T : Decodable, T : Encodable {
        FirebaseDatabaseManager.shared.save(object: object, at: collection, id: id, completion: completion)
    }
    
    func fetch<T>(from collection: String, id: String, as type: T.Type, completion: @escaping (Result<T, any Error>) -> Void) where T : Decodable, T : Encodable {
        FirebaseDatabaseManager.shared.fetch(from: collection, id: id, as: type, completion: completion)
    }
    
    func update<T>(_ object: T, at collection: String, id: String, completion: @escaping (Result<Void, any Error>) -> Void) where T : Decodable, T : Encodable {
        FirebaseDatabaseManager.shared.save(object: object, at: collection, id: id, completion: completion)
    }
    
    func delete(from collection: String, id: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        FirebaseDatabaseManager.shared.delete(from: collection, id: id, completion: completion)
    }
}
