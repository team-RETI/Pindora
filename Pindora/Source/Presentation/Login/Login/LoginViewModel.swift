//  LoginViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine

final class LoginViewModel {
    private let authUseCase: AuthUseCase
    private let userUseCase: UserUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authUseCase: AuthUseCase, userUseCase: UserUseCaseProtocol) {
        self.authUseCase = authUseCase
        self.userUseCase = userUseCase
    }
    
    
    /// Apple로그인을 트리거하는 메서드
    /// - Parameter viewController: 현재 UIViewController (보통 self)
    /// - Returns: User를 방출하는 Publisher
    func loginWithApple(from viewController: UIViewController) -> AnyPublisher<User, Error> {
        return authUseCase.signInWithApple()
    }
    
    func saveUser(_ user: User) -> AnyPublisher<Void, Error> {
        return userUseCase.saveUser(user: user)
    }
}
