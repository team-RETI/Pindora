//
//  AuthUseCaseImpl.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import Foundation
import Combine
import FirebaseAuth

final class AuthUseCaseImpl: AuthUseCaseProtocol {
    
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func requestAppleAuthorization() -> AnyPublisher<(idToken: String, rawNonce: String), UseCaseError> {
        return authRepository.requestAppleAuthorization()
            .mapError { RepositoryError.map(from: $0) }
            .mapError { UseCaseError.map(from: $0) }
            .eraseToAnyPublisher()
    }
    
    func authenticateWithApple(idToken: String, rawNonce: String) -> AnyPublisher<Void, UseCaseError> {
        return authRepository.authenticateWithApple(idToken: idToken, rawNonce: rawNonce)
            .mapError { RepositoryError.map(from: $0) }
            .mapError { UseCaseError.map(from: $0) }
            .eraseToAnyPublisher()
    }
}

final class StubAuthUseCaseImpl: AuthUseCaseProtocol {
    func requestAppleAuthorization() -> AnyPublisher<(idToken: String, rawNonce: String), UseCaseError> {
        let dummyIDToken = "mock_id_token_123"
        let dummyRawNonce = "mock_nonce_abc"
        
        return Just((idToken: dummyIDToken, rawNonce: dummyRawNonce))
            .setFailureType(to: UseCaseError.self)
            .eraseToAnyPublisher()
    }
    
    func authenticateWithApple(idToken: String, rawNonce: String) -> AnyPublisher<Void, UseCaseError> {
        return Just(())
            .setFailureType(to: UseCaseError.self)
            .eraseToAnyPublisher()
    }
}
