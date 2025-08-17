//
//  UserUseCaseImpl.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation
import Combine

final class UserUseCaseImpl: UserUseCaseProtocol {
    private let repository: DatabaseRepositoryProtocol
    private let collection = "Users"
    
    init(repository: DatabaseRepositoryProtocol) {
        self.repository = repository
    }
    
    func saveUser(user: User) -> AnyPublisher<Void, Error> {
        let dto = user.toDTO()
        return repository.create(dto, at: collection, id: user.userId)
    }
    
    func fetchUser(uid: String) -> AnyPublisher<User, Error> {
        return repository
            .fetch(from: collection, id: uid, as: UserDTO.self)
            .map { $0.toEntity() }
            .eraseToAnyPublisher()
    }
    
    func deleteUser(uid: String) -> AnyPublisher<Void, Error> {
        return repository.delete(from: collection, id: uid)
    }
}

final class StubUserUseCaseImpl: UserUseCaseProtocol {
    
    func saveUser(user: User) -> AnyPublisher<Void, Error> {
        print("Stub: 사용자 저장 \(user.userId)")
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchUser(uid: String) -> AnyPublisher<User, Error> {
        let dummyUser = User(
            userId: uid,
            userImage: nil,
            personaName: "Stub 유저",
            personaDescription: "테스트 설명",
            likedPlaces: []
        )
        return Just(dummyUser)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteUser(uid: String) -> AnyPublisher<Void, Error> {
        print("Stub: 사용자 삭제 \(uid)")
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
