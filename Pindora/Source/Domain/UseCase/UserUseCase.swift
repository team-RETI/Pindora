//
//  UserUseCase.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation
import Combine

protocol UserUseCaseprotocol {
    func saveUser(user: UserModel) -> AnyPublisher<Void, Error>
    func fetchUser(uid: String) -> AnyPublisher<UserModel, Error>
    func deleteUser(uid: String) -> AnyPublisher<Void, Error>
}
