//
//  UserUseCase.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation
import Combine

/// 사용자 정보를 저장, 조회, 삭제하는 유스케이스를 정의하는 프로토콜입니다.
protocol UserUseCaseProtocol {
    
    /// 사용자 정보를 Firestore에 저장합니다.
    /// - Parameter user: 저장할 사용자 정보 (UserModel).
    /// - Returns: 작업 완료 여부를 방출하는 AnyPublisher<Void, Error>
    func saveUser(user: User) -> AnyPublisher<Void, Error>
    
    /// 주어진 UID를 기준으로 사용자 정보를 조회합니다.
    /// - Parameter uid: 조회할 사용자의 고유 식별자.
    /// - Returns: 조회된 사용자 정보를 방출하는 AnyPublisher<UserModel, Error>
    func fetchUser(uid: String) -> AnyPublisher<User, Error>
    
    /// 주어진 UID를 기준으로 사용자 정보를 삭제합니다.
    /// - Parameter uid: 삭제할 사용자의 고유 식별자.
    /// - Returns: 작업 완료 여부를 방출하는 AnyPublisher<Void, Error>
    func deleteUser(uid: String) -> AnyPublisher<Void, Error>
}
