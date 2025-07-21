//
//  FirebaseDatabaseManager.swift
//  Pindora
//
//  Created by 장주진 on 7/21/25.
//

import Foundation
import FirebaseFirestore

final class FirebaseDatabaseManager {
    static let shared = FirebaseDatabaseManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func save<T: Codable>(object: T, at collection: String, id: String, completion: @escaping (Result<Void, Error>) -> Void){
        do {
            let data = try Firestore.Encoder().encode(object)
            db.collection(collection).document(id).setData(data) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetch<T: Codable>(from collection: String, id: String, as type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        db.collection(collection).document(id).getDocument { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let snapshot, let data = snapshot.data() else {
                completion(.failure(NSError(domain: "NoData", code: -1)))
                return
            }
            do {
                let json = try JSONSerialization.data(withJSONObject: data)
                let object = try JSONDecoder().decode(type, from: json)
                completion(.success(object))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func delete(from collection: String, id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collection).document(id).delete { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
