//
//  AuthRepositoryImpl.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import Foundation
import Combine
import FirebaseAuth

final class AuthRepositoryImpl: AuthRepository {
    private let authManager: FirebaseAuthManager
    
    init(authManager: FirebaseAuthManager = FirebaseAuthManager()) {
        self.authManager = authManager
    }
    
    func signInWithApple() -> AnyPublisher<FirebaseAuth.AuthDataResult, any Error> {
        return authManager.startSignInWithAppleFlow().eraseToAnyPublisher()
    }
}
