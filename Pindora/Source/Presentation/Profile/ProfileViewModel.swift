//  ProfileViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine

final class ProfileViewModel {
    @Published var personaName: String?
    @Published var personaDescription: String = ""
    @Published var userImageURL: String?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userUseCase: UserUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
    }
    
    func loadUser(with uid: String) {
        isLoading = true
        errorMessage = nil
        
        userUseCase.fetchUser(uid: uid).receive(on: RunLoop.main).sink { [weak self] completion in
            self?.isLoading = false
            if case let .failure(error) = completion {
                self?.errorMessage = "사용자 정보를 불러오지 못했습니다. \(error.localizedDescription)"
            }
        } receiveValue: { [weak self] user in
            self?.personaName = user.personaName
            self?.personaDescription = user.personaDescription
            self?.userImageURL = user.userImage
        }
        .store(in: &cancellables)
    }
}
