//
//  FirebaseDatabaseManager.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation
import FirebaseFirestore
import Combine

final class FirebaseDatabaseManager {
    static let shared = FirebaseDatabaseManager()
    private let db = Firestore.firestore()
    
    private init() {}
}

// MARK: - CRUD
extension FirebaseDatabaseManager {
    private func create(collection: String, documentID: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collection).document(documentID).setData(data) { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func read(collection: String, documentID: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        db.collection(collection).document(documentID).getDocument() { snapshot, error in
            if let error {
                completion(.failure(error))
            } else if let data = snapshot?.data() {
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "FireStoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "데이터를 찾을 수 없습니다."])))
            }
        }
    }
    
    private func update(collection: String, documentID: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collection).document(documentID).updateData(data) { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func delete(collection: String, documentID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collection).document(documentID).delete { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: - Combine Publishers
extension FirebaseDatabaseManager {
    func createGenericPublisher<T: Encodable>(collection: String, documentID: String, object: T) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            do {
                let data = try Firestore.Encoder().encode(object)
                self.create(collection: collection, documentID: documentID, data: data, completion: promise)
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func readGenericPublisher<T: Decodable>(
        collection: String,
        documentID: String,
        as type: T.Type
    ) -> AnyPublisher<T, Error> {
        Future<T, Error> { promise in
            self.read(collection: collection, documentID: documentID) { result in
                switch result {
                case .success(let data):
                    do {
                        let json = try JSONSerialization.data(withJSONObject: data)
                        let object = try JSONDecoder().decode(type, from: json)
                        promise(.success(object))
                    } catch {
                        promise(.failure(error))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateGenericPublisher<T: Encodable>(
        collection: String,
        documentID: String,
        with object: T
    ) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            do {
                let data = try Firestore.Encoder().encode(object)
                self.update(collection: collection, documentID: documentID, data: data, completion: promise)
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteGenericPublisher(
        collection: String,
        documentID: String
    ) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.delete(collection: collection, documentID: documentID, completion: promise)
        }.eraseToAnyPublisher()
    }
}
