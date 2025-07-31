//
//  UserUseCaseImpl.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation
import Combine

final class UserUseCaseImpl: UserUseCaseprotocol {
    private let repository: DatabaseRepositoryProtocol
    private let collection = "Users"
    
    init(repository: DatabaseRepositoryProtocol) {
        self.repository = repository
    }
    
    func saveUser(user: User) -> AnyPublisher<Void, any Error> {
        repository.create(user, at: collection, id: user.uid)
    }
    
    func fetchUser(uid: String) -> AnyPublisher<User, any Error> {
        repository.fetch(from: collection, id: uid, as: User.self)
    }
    
    func deleteUser(uid: String) -> AnyPublisher<Void, any Error> {
        repository.delete(from: collection, id: uid)
    }
}
