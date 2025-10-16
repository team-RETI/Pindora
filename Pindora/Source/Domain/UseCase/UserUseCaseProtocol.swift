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
//    /// 사용자가 저장한 장소 (홈,마이플레이스)
//    var savedPlacesPublisher: AnyPublisher<[Place], Never> { get }
//    /// 사용자의 장소로그 (프로필)
//    var placeLogPublisher: AnyPublisher<[Place], Never> { get }
    /// 사용자의 정보가 변경될때 호출되는 퍼블리셔
    var userPublisher: AnyPublisher<User?, Never> { get }
    
    /// 사용자의 장소 정보가 변경될 때 호출
    /// - Parameters:
    ///   - force: 강제호출 여부
    ///   - uid: 사용자 고유의 uid
    func refreshIfNeeded(force: Bool, uid: String)
    
    /// 사용자 정보를 Firestore에 저장합니다.
    /// - Parameter user: 저장할 사용자 정보 (UserModel).
    /// - Returns: 작업 완료 여부를 방출하는 AnyPublisher<Void, Error>
    func saveUser(user: User) -> AnyPublisher<Void, UseCaseError>
    
    /// 주어진 UID를 기준으로 사용자 정보를 조회합니다.
    /// - Parameter uid: 조회할 사용자의 고유 식별자.
    /// - Returns: 조회된 사용자 정보를 방출하는 AnyPublisher<UserModel, Error>
    func fetchUser(uid: String) -> AnyPublisher<User, UseCaseError>
    
    /// 사용자 정보를 업데이트 합니다
    /// - Parameter user: 저장할 사용자 정보 (UserModel).
    /// - Returns: 작업 완료 여부를 방출하는 AnyPublisher<Void, Error>
    func updateUser(user: User) -> AnyPublisher<Void, UseCaseError>
    
    /// 사용자가 장소를 저장하거나 삭제할 때 업데이트 합니다
    /// - Parameters:
    ///   - user: 사용자 정보
    ///   - place: 장소 정보
    /// - Returns: 작업 완료 여부 방출  AnyPublisher<Void, Error>
    func updateUserSavedPlaces(user: User, place: Place) -> AnyPublisher<Void, UseCaseError>
    
    /// 사용자가 장소를 클릭 시 로그 기록을 업데이트 합니다
    /// - Parameters:
    ///   - user: 사용자 정보
    ///   - place: 장소 정보
    /// - Returns: 작업 완료 여부 방출  AnyPublisher<Void, Error>
    func updateUserPlaceLog(user: User, place: Place) -> AnyPublisher<Void, UseCaseError>
    
    /// 주어진 UID를 기준으로 사용자 정보를 삭제합니다.
    /// - Parameter uid: 삭제할 사용자의 고유 식별자.
    /// - Returns: 작업 완료 여부를 방출하는 AnyPublisher<Void, Error>
    func deleteUser(uid: String) -> AnyPublisher<Void, UseCaseError>
}
