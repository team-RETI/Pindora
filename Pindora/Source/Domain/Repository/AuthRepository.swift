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
protocol AuthRepository {
    
    /// Apple 계정을 사용하여 로그인합니다.
    /// - Returns:
    ///     - `AnyPublisher<AuthDataResult, Error>`:
    ///     - 성공 시 Firebase Auth의 `AuthDataResult`를 방출합니다.
    ///     - 실패 시 `Error`를 방출합니다.
    func signInWithApple() -> AnyPublisher<AuthDataResult, Error>
}
