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
