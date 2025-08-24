//
//  AuthUseCase.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import Foundation
import Combine

/// 인증 관련 유즈케이스를 정의합니다.
/// Apple 로그인 로직을 처리하고 도메인 계층의 `User` 모델로 변환합니다.
protocol AuthUseCaseProtocol {
    
    /// Apple 인증을 요청합니다.
    ///
    /// - Returns:
    ///   `AnyPublisher<(idToken: String, rawNonce: String), LoginError>`
    ///   - 성공 시 Apple 로그인에서 발급된 ID 토큰과 nonce 값을 튜플로 반환합니다.
    ///   - 실패 시 `LoginError`를 방출합니다.
    ///
    /// 이 메서드는 Apple의 인증 플로우를 시작하고,
    /// Firebase 인증에 사용할 ID 토큰과 nonce를 반환합니다.
    
    func requestAppleAuthorization() -> AnyPublisher<(idToken: String, rawNonce: String), UseCaseError>
    
    /// Apple 인증 정보를 사용하여 Firebase에 로그인합니다.
    ///
    /// - Parameters:
    ///   - idToken: Apple 로그인에서 발급된 ID 토큰입니다.
    ///   - rawNonce: 인증 요청 시 사용된 nonce 값입니다.
    ///
    /// - Returns:
    ///   `AnyPublisher<Void, LoginError>`
    ///   - 성공 시 `Void`를 반환합니다.
    ///   - 실패 시 `LoginError`를 방출합니다.
    ///
    /// 이 메서드는 Apple 로그인에서 받은 토큰 정보를 기반으로
    /// Firebase Authentication에 사용자 로그인을 요청합니다.
    func authenticateWithApple(idToken: String, rawNonce: String) -> AnyPublisher<Void, UseCaseError>
}
