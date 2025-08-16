//
//  UserUseCaseImpl.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation
import Combine
import FirebaseFirestore


final class UserUseCaseImpl: UserUseCaseProtocol {
    private let repository: DatabaseRepositoryProtocol
    private let collection = "Users"
    
    init(repository: DatabaseRepositoryProtocol) {
        self.repository = repository
    }
    
    func saveUser(user: User) -> AnyPublisher<Void, ServiceError> {
        let dto = user.toDTO()
        return repository.create(dto, at: collection, id: user.userId)
            .mapError { ServiceError.error($0) }
            .eraseToAnyPublisher()
    }
    
    func fetchUser(uid: String) -> AnyPublisher<User, ServiceError> {
        return repository
            .fetch(from: collection, id: uid, as: UserDTO.self)
            .map { $0.toEntity() }
            .mapError { error in
                let nsError = error as NSError

                // ✅ code만 가지고 판단
                if nsError.code == FirestoreErrorCode.notFound.rawValue {
                    print("✅ userNotFound 로 매핑됨")
                    return .userNotFound
                } else {
                    print("❌ 알 수 없는 에러로 error(...)에 래핑됨")
                    return .error(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteUser(uid: String) -> AnyPublisher<Void, ServiceError> {
        return repository.delete(from: collection, id: uid)
            .mapError { ServiceError.error($0) }
            .eraseToAnyPublisher()
    }
}

final class StubUserUsecaseImpl: UserUseCaseProtocol {
    func saveUser(user: User) -> AnyPublisher<Void, ServiceError> {
        // 즉시 성공 반환
        return Just(())
            .setFailureType(to: ServiceError.self)
            .eraseToAnyPublisher()
    }
    
    func fetchUser(uid: String) -> AnyPublisher<User, ServiceError> {
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
            .setFailureType(to: ServiceError.self)
            .eraseToAnyPublisher()
    }
    
    func deleteUser(uid: String) -> AnyPublisher<Void, ServiceError> {
        // 즉시 성공 반환
        return Just(())
            .setFailureType(to: ServiceError.self)
            .eraseToAnyPublisher()
    }
}
