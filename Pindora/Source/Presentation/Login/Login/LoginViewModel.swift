//  LoginViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine
import FirebaseAuth

final class LoginViewModel {
    private let authUseCase: AuthUseCaseProtocol
    private let userUseCase: UserUseCaseProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(authUseCase: AuthUseCaseProtocol, userUseCase: UserUseCaseProtocol) {
        self.authUseCase = authUseCase
        self.userUseCase = userUseCase
    }
    
    struct Input {
        let appleLoginTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        /// loginResultSubject를 읽기 전용으로 감싼 것
        /// 외부에서 .send() 불가능하고 구독만 허용
        /// eraseToAnyPublisher로 타입을 숨겨서 내부 구현이 바뀌어도 외부 코드는 유지 가능
        let loginResult: AnyPublisher<Result<Void, ServiceError>, Never>
    }
    
    func transform(input: Input) -> Output {
        /// ViewModel 내부에서 이벤트를 발행하는 실제 주체
        let loginResultSubject = PassthroughSubject<Result<Void, ServiceError>, Never>()
        
        input.appleLoginTapped
            // 1) 애플 로그인 인증
            /// input: Void
            /// output: AnyPublisher<(idToken, rawNonce), ServiceError>
            .flatMap { [weak self] in
                guard let self = self else {
                    return Empty<(idToken: String, rawNonce: String), ServiceError>().eraseToAnyPublisher()
                }
                return self.authUseCase.requestAppleAuthorization()
            }
            // 2) Firebase Auth 인증
            /// input: idToken, rawNonce
            /// output: AnyPublisher<Void, ServiceError>
            .flatMap { [weak self] (idToken, rawNonce) in
                guard let self = self else {
                    return Empty<Void, ServiceError>().eraseToAnyPublisher()
                }
                return self.authUseCase.authenticateWithApple(idToken: idToken, rawNonce: rawNonce)
            }
            // 3) Realtime DB에 유저 존재 여부 확인(기존유저: 정보 가져오기, 신규유저: 회원가입)
            /// input: Void
            /// output: AnyPublisher<Void, ServiceError>
            .flatMap { [weak self] _ -> AnyPublisher<Void, ServiceError> in
                guard let self = self else {
                    return Fail(error: .invalidState).eraseToAnyPublisher()
                }
                
                guard let uid = Auth.auth().currentUser?.uid else {
                    return Fail(error: .invalidState).eraseToAnyPublisher()
                }
                
                return self.userUseCase.fetchUser(uid: uid)
                    .map { user in
                        print("✅ 기존 유저 로그인: \(String(describing: user.personaName))")
                        return ()
                    }
                    .catch { error -> AnyPublisher<Void, ServiceError> in
                        switch error {
                        case .userNotFound:
                            print("🆕 신규 유저입니다. Firestore에 저장을 시작합니다.")
                            
                            let newUser = User(
                                userId: uid,
                                userImage: "https://example.com/default_profile.png",
                                personaName: "초보 도시 탐험가",
                                personaDescription: "",
                                likedPlaces: [],
                                savedPlaces: [],
                                visitedPlaces: []
                            )
                            
                            return self.userUseCase.saveUser(user: newUser)
                                .handleEvents(receiveCompletion: { completion in
                                    if case .finished = completion {
                                        print("✅ 신규 유저 Firestore 저장 완료")
                                    }
                                })
                                .eraseToAnyPublisher()
                            
                        default:
                            print("❌ 알 수 없는 오류: \(error)")
                            return Fail(error: error).eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            }
            /// input: Void
            /// output: Result<Void, ServiceError>
            /// Void를 Result.success(())로 감싸는 용도
            .map { _ in Result<Void, ServiceError>.success(()) }
            /// input: Void
            /// output: Just<Result<Void, ServiceError>>
            /// 에러를 Void를 Result.success(())로 감싸는 용도
            .catch { error -> Just<Result<Void, ServiceError>> in
                Just(.failure(error))
            }
            /// input: Result<Void, ServiceError>
            .sink { result in
                loginResultSubject.send(result)
            }
            .store(in: &cancellables)
        
        return Output(loginResult: loginResultSubject.eraseToAnyPublisher())
    }
    
}

