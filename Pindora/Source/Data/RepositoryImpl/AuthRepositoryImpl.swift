//
//  AuthRepositoryImpl.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import Foundation
import Combine
import FirebaseAuth

final class AuthRepositoryImpl: AuthRepositoryProtocol {
    private let authManager: FirebaseAuthManager
    
    init(authManager: FirebaseAuthManager = FirebaseAuthManager()) {
        self.authManager = authManager
    }
    
    func requestAppleAuthorization() -> AnyPublisher<(idToken: String, rawNonce: String), InfraError> {
        return authManager.requestAppleAuthorization()
    }
    
    func authenticateWithApple(idToken: String, rawNonce: String) -> AnyPublisher<Void, InfraError> {
        return authManager.authenticateWithApple(idToken: idToken, rawNonce: rawNonce)
    }
}
