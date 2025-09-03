//  ProfileViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine
import FirebaseAuth

final class ProfileViewModel {
    @Published var user: User?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userUseCase: UserUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private let gptUseCase: GPTUseCaseProtocol

    init(userUseCase: UserUseCaseProtocol, gptUseCase: GPTUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.gptUseCase = gptUseCase
        loadUser()
    }
    
//    init(userUseCase: UserUseCaseProtocol) {
//        self.userUseCase = userUseCase
//        loadUser()
//    }
    
    func generatePersona(for location: [String]) {
        gptUseCase.createPersonaNameAndDescription(from: location)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("GPT 에러: \(error)")
                }
            }, receiveValue: { [weak self] result in
                self?.user?.personaName = result.name
                self?.user?.personaDescription = result.description
                print("이름: \(result.name), 설명: \(result.description)")
                self?.savePersonaToFirestore(name: result.name, description: result.description)
            })
            .store(in: &cancellables)
    }
    
    func savePersonaToFirestore(name: String, description: String) {
        guard var currentUser = user else {
            print("❌ 현재 사용자 없음")
            return
        }
        currentUser.personaName = name
        currentUser.personaDescription = description

        userUseCase.saveUser(user: currentUser)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("🔥 Firestore 저장 실패: \(error)")
                } else {
                    print("✅ Firestore 저장 완료!")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func loadUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "로그인된 사용자가 없습니다."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        userUseCase.fetchUser(uid: uid)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = "사용자 정보를 불러오지 못함: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] user in
                print("유저 데이터: \(user)") //가져오는 데이터 확인용 나중에 삭제할 예정
                self?.user = user
            }
            .store(in: &cancellables)
    }
}
