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
protocol AuthUseCase {
    
    /// Apple 계정을 사용하여 로그인합니다.
    /// - Returns:
    ///     - `AnyPublisher<User, Error>`:
    ///     - 성공 시 로그인된 사용자의 `User` 객체를 방출합니다.
    ///     - 실패 시 `Error`를 방출합니다.
    func signInWithApple() -> AnyPublisher<User, Error>
}
