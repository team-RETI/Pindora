//
//  AuthUseCase.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import Foundation
import Combine

protocol AuthUseCase {
    func signInWithApple() -> AnyPublisher<User, Error>
}
