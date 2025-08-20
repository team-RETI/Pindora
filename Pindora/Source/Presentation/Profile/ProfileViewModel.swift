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
    
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
        loadUser()
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
