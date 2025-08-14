//
//  DatabaseRepository.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation
import Combine

/// Firestore 데이터베이스와의 기본 CRUD 작업을 수행하는 레포지토리 프로토콜입니다.
/// 제네릭 Codable 객체를 사용하여 생성, 조회, 업데이트, 삭제 기능을 제공합니다.
public protocol DatabaseRepositoryProtocol {
    
    /// Firestore에 객체를 생성(저장)합니다.
    /// - Parameters:
    ///   - object: Firestore에 저장할 Codable 객체입니다.
    ///   - collection: 저장할 컬렉션의 이름입니다.
    ///   - id: 생성할 문서의 고유 ID입니다.
    /// - Returns: 작업의 성공 여부를 방출하는 AnyPublisher<Void, Error>입니다.
    func create<T: Codable>(_ object: T, at collection: String, id: String) -> AnyPublisher<Void, Error>
    
    /// Firestore에서 특정 문서를 조회하여 객체로 반환합니다.
    /// - Parameters:
    ///   - collection: 조회할 컬렉션의 이름입니다.
    ///   - id: 조회할 문서의 ID입니다.
    ///   - type: 반환받을 객체의 타입입니다.
    /// - Returns: 디코딩된 객체를 방출하는  AnyPublisher<T, Error>입니다.
    func fetch<T: Codable>(from collection: String, id: String, as type: T.Type) -> AnyPublisher<T, Error>
    
    /// <#Description#>
    /// - Parameters:
    ///   - collection: <#collection description#>
    ///   - type: <#type description#>
    /// - Returns: <#description#>
    func fetchAll<T:Codable>(from collection: String, as type: T.Type) -> AnyPublisher<[T], Error>
    
    /// Firestore의 특정 문서를 업데이트합니다.
    /// - Parameters:
    ///   - object: Firestore에 저장할 Codable 객체입니다.
    ///   - collection: 업데이트할 컬렉션의 이름입니다.
    ///   - id: 업데이트할 문서의 ID입니다.
    /// - Returns: 작업의 성공 여부를 방출하는 AnyPublisher<Void, Error>입니다.
    func update<T: Codable>(_ object: T, at collection: String, id: String) -> AnyPublisher<Void, Error>
    
    /// Firestore에서 특정 문서를 삭제합니다.
    /// - Parameters:
    ///   - collection: 삭제할 컬렉션의 이름입니다.
    ///   - id: 삭제할 문서의 ID입니다.
    /// - Returns: 작업의 성공 여부를 방출하는 AnyPublisher<Void, Error>입니다.
    func delete(from collection: String, id: String) -> AnyPublisher<Void, Error>
}
