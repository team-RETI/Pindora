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
            .mapToUseCaseError()
            .eraseToAnyPublisher()
    }
    
    func fetchUser(uid: String) -> AnyPublisher<User, UseCaseError> {
        return repository
            .fetch(from: collection, id: uid, as: UserDTO.self)
            .map { $0.toEntity() }
            .mapToUseCaseError()
            .eraseToAnyPublisher()
    }
    
    func deleteUser(uid: String) -> AnyPublisher<Void, UseCaseError> {
        return repository.delete(from: collection, id: uid)
            .mapToUseCaseError()
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
            .mapError { UseCaseError.map(from: $0 as! RepositoryError) }
            .eraseToAnyPublisher()
    }

    func deleteUser(uid: String) -> AnyPublisher<Void, UseCaseError> {
        // 더미 성공 반환
        return Just(())
            .setFailureType(to: UseCaseError.self)
            .eraseToAnyPublisher()
    }
}


// .mapError { UseCaseError.map(from: $0 as! RepositoryError) }
extension Publisher where Failure == Error {
    func mapToUseCaseError() -> Publishers.MapError<Self, UseCaseError> {
        self.mapError { error in
            if let repo = error as? RepositoryError {
                return UseCaseError.map(from: repo)
            } else if let infra = error as? InfraError {
                return UseCaseError.map(from: RepositoryError.map(from: infra)) // ✅ 깔끔하게
            } else {
                return .unknown(.unknown(.unknown(error)))
            }
        }
    }
}
