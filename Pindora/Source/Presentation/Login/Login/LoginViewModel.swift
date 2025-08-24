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
        let loginResult: AnyPublisher<Result<Void, UseCaseError>, Never>
    }
    func transform(input: Input) -> Output {
        let loginResult: AnyPublisher<Result<Void, UseCaseError>, Never> = input.appleLoginTapped
            .map { [weak self] _ -> AnyPublisher<Result<Void, UseCaseError>, Never> in
                guard let self = self else {
                    return Just(.failure(.invalidState)).eraseToAnyPublisher()
                }

                // 1) 애플 로그인 인증
                /// input: Void
                /// output: AnyPublisher<(idToken, rawNonce), UseCaseError>
                return self.authUseCase.requestAppleAuthorization()
                    
                    // 2) Firebase Auth 인증
                    /// input: idToken, rawNonce
                    /// output: AnyPublisher<Void, UseCaseError>
                    .flatMap { [weak self] (idToken, rawNonce) in
                        guard let self = self else {
                            return Empty<Void, UseCaseError>().eraseToAnyPublisher()
                        }
                        return self.authUseCase.authenticateWithApple(idToken: idToken, rawNonce: rawNonce)
                    }
                    // 3) Realtime DB에 유저 존재 여부 확인(기존유저: 정보 가져오기, 신규유저: 회원가입)
                    /// input: Void
                    /// output: AnyPublisher<Void, UseCaseError>
                    .flatMap { [weak self] _ -> AnyPublisher<Void, UseCaseError> in
                        guard let self = self else {
                            return Fail(error: .invalidState).eraseToAnyPublisher()
                        }

                        guard let uid = Auth.auth().currentUser?.uid else {
                            return Fail(error: .invalidState).eraseToAnyPublisher()
                        }

                        return self.userUseCase.fetchUser(uid: uid)
                            .map { user in
                                print("✅ 기존 유저 로그인: \(String(describing: user))")
                                return ()
                            }
                            .catch { error -> AnyPublisher<Void, UseCaseError> in
                                switch error {
                                case .userNotFound:
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
                    /// 성공 시 Result.success(())로 래핑
                    .map { Result<Void, UseCaseError>.success(()) }
                    /// 에러 시 Result.failure(...)로 변환
                    .catch { error in Just(.failure(error)) }
                    .eraseToAnyPublisher()
            }
            .switchToLatest() // ✅ 버튼 누를 때마다 새로 실행됨
            .eraseToAnyPublisher()

        return Output(loginResult: loginResult)
    }

}
