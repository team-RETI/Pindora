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
    
    func saveUser(user: User) -> AnyPublisher<Void, UseCaseError> {
        let dto = user.toDTO()
        return repository.create(dto, at: collection, id: user.userId)
            .mapError { UseCaseError.unknown($0) }
            .eraseToAnyPublisher()
    }
    
    func fetchUser(uid: String) -> AnyPublisher<User, UseCaseError> {
        return repository
            .fetch(from: collection, id: uid, as: UserDTO.self)
            .map { $0.toEntity() }
            .mapError { UseCaseError.unknown($0) }
            .eraseToAnyPublisher()
    }
    
    func deleteUser(uid: String) -> AnyPublisher<Void, UseCaseError> {
        return repository.delete(from: collection, id: uid)
            .mapError { UseCaseError.unknown($0) }
            .eraseToAnyPublisher()
    }
}

final class StubUserUsecaseImpl: UserUseCaseProtocol {
    private let repository: DatabaseRepositoryProtocol = DatabaseRepositoryImpl() // 실제 구현체 사용
    private let testUID = "f3BXGDk6b8eUWAU2xPPATH1honm1" // ✅ 고정 테스트 UID

    init() {} // 매개변수 없이 생성 가능

    func saveUser(user: User) -> AnyPublisher<Void, UseCaseError> {
        // 여전히 더미 동작
        return Just(())
            .setFailureType(to: UseCaseError.self)
            .eraseToAnyPublisher()
    }

    func fetchUser(uid: String) -> AnyPublisher<User, UseCaseError> {
        return repository
            .fetch(from: "Users", id: testUID, as: UserDTO.self)
            .map { $0.toEntity() }
            .mapError { UseCaseError.unknown($0) }
            .eraseToAnyPublisher()
    }

    func deleteUser(uid: String) -> AnyPublisher<Void, UseCaseError> {
        // 더미 성공 반환
        return Just(())
            .setFailureType(to: UseCaseError.self)
            .eraseToAnyPublisher()
    }
}





//            .mapError { error in
//                let nsError = error as NSError
//
//                // ✅ code만 가지고 판단
//                if nsError.code == FirestoreErrorCode.notFound.rawValue {
//                    print("✅ userNotFound 로 매핑됨")
//                    return .userNotFound
//                } else {
//                    print("❌ 알 수 없는 에러로 error(...)에 래핑됨")
//                    return .error(error)
//                }
//            }


/*
final class StubUserUsecaseImpl: UserUseCaseProtocol {
    func saveUser(user: User) -> AnyPublisher<Void, DomainError> {
        // 즉시 성공 반환
        return Just(())
            .setFailureType(to: DomainError.self)
            .eraseToAnyPublisher()
    }
    
    func fetchUser(uid: String) -> AnyPublisher<User, DomainError> {
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
            .setFailureType(to: DomainError.self)
            .eraseToAnyPublisher()
    }
    
    func deleteUser(uid: String) -> AnyPublisher<Void, DomainError> {
        // 즉시 성공 반환
        return Just(())
            .setFailureType(to: DomainError.self)
            .eraseToAnyPublisher()
    }
}
*/
