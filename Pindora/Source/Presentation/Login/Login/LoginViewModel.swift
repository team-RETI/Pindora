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
    private let placeUsease: PlaceUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    init(authUseCase: AuthUseCaseProtocol, userUseCase: UserUseCaseProtocol, placeUsecase: PlaceUseCase) {
        self.authUseCase = authUseCase
        self.userUseCase = userUseCase
        self.placeUsease = placeUsecase
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

// MARK: - OTA 관련 메서드
/*
 Input/Output을 새로 만든 이유: OTA에서는 appleLoginTapped가 필요없지만 하나의 Input으로 관리하면 억지로 넣어줘야함
 해결 방법으로는 뷰마다 Input을 만들어주거나 enum으로 Input을 관리하면 되는데 기존 코드를 건들지 않기 위해 OTAInput 구현하였음
 */
extension LoginViewModel {
    
    struct OTAInput {
        let updateCategories: AnyPublisher<[String], Never>
        let fetchRecommendKeyword: AnyPublisher<Void, Never>
    }
    
    struct OTAOutput {
        let categoryUpdateResult: AnyPublisher<Result<Void, UseCaseError>, Never>
        let recommendKeywords: AnyPublisher<Result<[String], UseCaseError>, Never>
    }
    
    func transform(input: OTAInput) -> OTAOutput {
        let categoruUpdateResult = input.updateCategories
            .flatMap { [weak self] categories -> AnyPublisher<Result<Void, UseCaseError>, Never> in
                guard let self, let uid = Auth.auth().currentUser?.uid else {
                    return Just(.failure(.invalidState)).eraseToAnyPublisher()
                }
                
                return self.userUseCase.fetchUser(uid: uid)
                    .flatMap { user -> AnyPublisher<Void, UseCaseError> in
                        var updated = user
                        updated.selectedCategories = categories
                        return self.userUseCase.saveUser(user: updated)
                    }
                    .map { Result<Void, UseCaseError>.success(()) }
                    .catch { error in Just(.failure(error)) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        let recommendKeywords = input.fetchRecommendKeyword
            .flatMap { [weak self] _ -> AnyPublisher<Result<[String], UseCaseError>, Never> in
                guard let self else {
                    return Just(.failure(.invalidState)).eraseToAnyPublisher()
                }

                return self.placeUsease.fetchRecommendKeyword()
                    .map { Result.success($0) }
                    .catch { error in Just(.failure(.unknown(.unknown(error as! InfraError)))) }
                    .handleEvents(receiveOutput: { result in
                        switch result {
                        case .success(let keywords):
                            print("📦 추천 키워드:", keywords)
                        case .failure(let error):
                            print("❌ 추천 키워드 로드 실패:", error)
                        }
                    })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        return OTAOutput(categoryUpdateResult: categoruUpdateResult, recommendKeywords: recommendKeywords)
    }
}
