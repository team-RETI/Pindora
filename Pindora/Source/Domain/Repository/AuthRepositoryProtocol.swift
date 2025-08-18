//
//  AuthRepository.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import Foundation
import Combine
import FirebaseAuth

/// Apple 인증과 관련된 저장소 역할을 정의합니다.
/// 이 프로토콜은 Apple 로그인 요청을 수행하고 결과를 Firebase Auth와 연동합니다.
protocol AuthRepositoryProtocol {
    
    /// Apple ID 인증을 요청하여 사용자 정보를 받아옵니다.
    ///
    /// - Returns:
    ///   `AnyPublisher<(idToken: String, rawNonce: String), Error>`를 반환합니다.
    ///   - 성공 시 `idToken`과 `rawNonce` 쌍을 전달합니다.
    ///   - 실패 시 `Error`를 방출합니다.
    ///
    /// 이 메서드는 Apple 로그인 UI를 띄우고, 사용자의 인증 정보를 받아와
    /// Firebase 연동에 필요한 토큰을 제공합니다.
    func requestAppleAuthorization() -> AnyPublisher<(idToken: String, rawNonce: String), InfraError>
    
    
    /// Apple 인증 정보를 사용하여 Firebase에 로그인합니다.
    ///
    /// - Parameters:
    ///   - idToken: Apple 로그인에서 발급된 ID 토큰입니다.
    ///   - rawNonce: 인증 요청 시 사용된 nonce 값입니다.
    ///
    /// - Returns:
    ///   `AnyPublisher<Void, Error>`
    ///   - 성공 시 `Void`를 반환합니다.
    ///   - 실패 시 `Error`를 방출합니다.
    ///
    /// 이 메서드는 Apple 로그인에서 받은 토큰 정보를 기반으로
    /// Firebase Authentication에 사용자 로그인을 요청합니다.
    ///
    /// - 참고: 이 메서드는 Firebase 측에서 사용자가 처음 로그인하는 경우에는
    ///        새 계정을 생성하고, 기존 사용자인 경우에는 해당 계정으로 로그인합니다.
    func authenticateWithApple(idToken: String, rawNonce: String) -> AnyPublisher<Void, InfraError>

}
