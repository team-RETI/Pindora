//
//  UserUseCaseImpl.swift
//  Pindora
//
//  Created by 장주진 on 7/21/25.
//

import Foundation

final class UserUseCaseImpl: UserUseCaseprotocol {
    private let repository: DatabaseRepositoryProtocol
    private let collection = "Users"
    
    init(repository: DatabaseRepositoryProtocol) {
        self.repository = repository
    }
    
    func saveUser(user: UserModel, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.create(user, at: collection, id: user.uid, completion: completion)
    }
    
    func fetchUser(uid: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        repository.fetch(from: collection, id: uid, as: UserModel.self, completion: completion)
    }
    
    func deleteUser(uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.delete(from: collection, id: uid, completion: completion)
    }
}
