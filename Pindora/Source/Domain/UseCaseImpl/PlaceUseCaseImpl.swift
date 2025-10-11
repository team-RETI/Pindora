//
//  PlaceUseCaseImpl.swift
//  Pindora
//
//  Created by 장주진 on 8/4/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class PlaceUseCaseImpl: PlaceUseCase {
    private let repository: DatabaseRepositoryProtocol
    private let collection = "Places"
    
    init(repository: DatabaseRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchPlaces() -> AnyPublisher<[Place], any Error> {
        repository.fetchAll(from: collection, as: PlaceDTO.self)
            .map { $0.map { $0.toEntity() } }
            .eraseToAnyPublisher()
    }
    
    func savePlace(place: Place) -> AnyPublisher<Void, UseCaseError> {
        guard let userId = Auth.auth().currentUser?.uid else {
            return Fail(error: UseCaseError.userNotFound).eraseToAnyPublisher()
        }

        let data = place.toDictionary()
        let userRef = Firestore.firestore().collection("Users").document(userId)

        return Future<Void, Error> { promise in
            userRef.updateData([
                "savedPlaces": FieldValue.arrayUnion([data])
            ]) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .mapToUseCaseError()
        .eraseToAnyPublisher()
    }
    
    func fetchKeywords() -> AnyPublisher<[String], Error> {
        repository.fetch(from: "Keywords", id: "Recommand", as: KeywordDTO.self)
            .map { $0.words }
            .eraseToAnyPublisher()
    }
}
