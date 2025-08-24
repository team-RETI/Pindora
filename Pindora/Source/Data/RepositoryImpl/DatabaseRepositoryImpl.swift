//
//  DatabaseRepositoryImpl.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation
import Combine

final class DatabaseRepositoryImpl: DatabaseRepositoryProtocol {
    func create<T>(_ object: T, at collection: String, id: String) -> AnyPublisher<Void, any Error> where T : Decodable, T : Encodable {
        FirebaseDatabaseManager.shared.createGenericPublisher(collection: collection, documentID: id, object: object)
    }
    
    func fetch<T>(from collection: String, id: String, as type: T.Type) -> AnyPublisher<T, any Error> where T : Decodable, T : Encodable {
        FirebaseDatabaseManager.shared.readGenericPublisher(collection: collection, documentID: id, as: type)
    }
    
    func fetchAll<T>(from collection: String, as type: T.Type) -> AnyPublisher<[T], any Error> where T : Decodable, T : Encodable {
        FirebaseDatabaseManager.shared.readAllGenericPublisher(collection: collection, as: type)
    }
    
    func update<T>(_ object: T, at collection: String, id: String) -> AnyPublisher<Void, any Error> where T : Decodable, T : Encodable {
        FirebaseDatabaseManager.shared.updateGenericPublisher(collection: collection, documentID: id, with: object)
    }
    
    func delete(from collection: String, id: String) -> AnyPublisher<Void, any Error> {
        FirebaseDatabaseManager.shared.deleteGenericPublisher(collection: collection, documentID: id)
    }
}
