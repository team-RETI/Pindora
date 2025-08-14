//  LoginViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine

enum LoginError: Error {
    case invalidCredential
    
    var description: String {
        switch self {
        case .invalidCredential:
            "⚠️ 애플 인증 오류"
        }
    }
}

final class LoginViewModel {
    private let authUseCase: AuthUseCaseProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
    }
    
    struct Input {
        let appleLoginTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        /// loginResultSubject를 읽기 전용으로 감싼 것
        /// 외부에서 .send() 불가능하고 구독만 허용
        /// eraseToAnyPublisher로 타입을 숨겨서 내부 구현이 바뀌어도 외부 코드는 유지 가능
        let loginResult: AnyPublisher<Result<Void, Error>, Never>
    }
    
    func transform(input: Input) -> Output {
        /// ViewModel 내부에서 이벤트를 발행하는 실제 주체
        let loginResultSubject = PassthroughSubject<Result<Void, Error>, Never>()
        input.appleLoginTapped
            .flatMap {
                self.authUseCase.signInWithApple()
                    .map { user in
                        print("로그인 성공")
                        let mirror = Mirror(reflecting: user)
                        for child in mirror.children {
                            if let propertyName = child.label {
                                print("\(propertyName): \(child.value)")
                            }
                        }
                        return .success(())
                    }
                    .catch { error in
                        Just(Result<Void, Error>.failure(error))
                    }
            }
            .sink { result in
                // print("애플 로그인 버튼 탭됨 - 성공 이벤트 발생")
                // loginResultSubject.send(.success(()))
                
                // loginResultSubject.send(.failure(LoginError.invalidCredential))
                // print(LoginError.invalidCredential.description)
                
                loginResultSubject.send(result)
            }
            .store(in: &cancellables)
        
        
        return Output(loginResult: loginResultSubject.eraseToAnyPublisher())
    }
}

