//
//  AuthUseCaseImpl.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import Foundation
import Combine
import FirebaseAuth

//enum LoginError: LocalizedError {
//    case invalidCredential
//    case userNotFound
//    case error(Error)
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidCredential:
//            return "⚠️ 유효하지 않은 Credential입니다."
//        case .userNotFound:
//            return "⚠️ 해당 유저를 찾을 수 없습니다."
//        case .error(let error):
//            return "⚠️ 알 수 없음: \(error.localizedDescription)"
//        }
//    }
//}

//extension Error {
//    func toLoginError() -> LoginError {
//        let e = self as NSError
//        if e.domain == AuthErrorDomain {
//            switch e.code {
//            case AuthErrorCode.userNotFound.rawValue:
//                return .userNotFound
//            case AuthErrorCode.invalidCredential.rawValue:
//                return .invalidCredential
//            default:
//                break
//            }
//        }
//        return .error(self) // 나머지는 그대로 래핑
//    }
//}

final class AuthUseCaseImpl: AuthUseCaseProtocol {
    
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func requestAppleAuthorization() -> AnyPublisher<(idToken: String, rawNonce: String), DomainError> {
        return authRepository.requestAppleAuthorization()
            .mapError { DomainError.error($0) }
            .eraseToAnyPublisher()
    }
    
    func authenticateWithApple(idToken: String, rawNonce: String) -> AnyPublisher<Void, DomainError> {
        return authRepository.authenticateWithApple(idToken: idToken, rawNonce: rawNonce)
            .mapError { DomainError.error($0) }
            .eraseToAnyPublisher()
    }
}

final class StubAuthUseCaseImpl: AuthUseCaseProtocol {
    func requestAppleAuthorization() -> AnyPublisher<(idToken: String, rawNonce: String), DomainError> {
        let dummyIDToken = "mock_id_token_123"
        let dummyRawNonce = "mock_nonce_abc"
        
        return Just((idToken: dummyIDToken, rawNonce: dummyRawNonce))
            .setFailureType(to: DomainError.self)
            .eraseToAnyPublisher()
    }
    
    func authenticateWithApple(idToken: String, rawNonce: String) -> AnyPublisher<Void, DomainError> {
        return Just(())
            .setFailureType(to: DomainError.self)
            .eraseToAnyPublisher()
    }
}
