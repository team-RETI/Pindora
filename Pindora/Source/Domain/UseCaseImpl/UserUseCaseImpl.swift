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

final class StubUserUsecaseImpl: UserUseCaseProtocol {
    func saveUser(user: User) -> AnyPublisher<Void, any Error> {
        // 즉시 성공 반환
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchUser(uid: String) -> AnyPublisher<User, any Error> {
        // User 모델을 그대로 활용한 더미 유저 생성
        let dummyUser = User(
            userId: uid,
            userImage: "https://example.com/dummy_profile.png",
            personaName: "테스트 유저",
            personaDescription: "3개의 장소를 저장해보세요.",
            likedPlaces: [],
            savedPlaces: [],
            visitedPlaces: []
        )
        return Just(dummyUser)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteUser(uid: String) -> AnyPublisher<Void, any Error> {
        // 즉시 성공 반환
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
