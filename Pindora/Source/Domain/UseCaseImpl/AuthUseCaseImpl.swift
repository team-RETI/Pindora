//
//  AuthUseCaseImpl.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import Foundation
import Combine
import FirebaseAuth

final class AuthUseCaseImpl: AuthUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func signInWithApple() -> AnyPublisher<User, any Error> {
        return authRepository.signInWithApple().map{ User(from: $0.user) }.eraseToAnyPublisher()
    }
}

final class StubAuthUseCaseImpl: AuthUseCase {
    func signInWithApple() -> AnyPublisher<User, Error> {
        let dummyUser = User(
            userId: "12345",
            userImage: nil,
            personaName: "테스트 유저",
            personaDescription: "Stub Persona",
            likedPlaces: []
        )
        return Just(dummyUser)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
