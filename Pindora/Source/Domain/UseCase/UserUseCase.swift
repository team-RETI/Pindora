//
//  UserUseCase.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation

protocol UserUseCaseprotocol {
    func saveUser(user: UserModel, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchUser(uid: String, completion: @escaping (Result<UserModel, Error>) -> Void)
    func deleteUser(uid: String, completion: @escaping (Result<Void, Error>) -> Void)
}
