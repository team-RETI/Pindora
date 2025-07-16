//
//  AuthUseCaseImpl.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import Foundation

final class AuthUseCaseImpl: AuthUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
}
