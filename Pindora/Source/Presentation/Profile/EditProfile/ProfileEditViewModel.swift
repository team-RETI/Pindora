//
//  ProfileEditViewModel.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//

import UIKit
import Combine

final class ProfileEditViewModel {
    enum ImageType: String, CaseIterable {
        case memoji = "Memoji"
        case custom = "커스텀"
        case color = "컬러"
    }
    
    var selectedImageType: ImageType = .memoji
    var personaTitle: String = "즉흥적인 도시 탐험가"
    var personaDescription: String = "조용한 카페를 선호하고 갑작스럽게 화장실을 자주가며 고즈넉한 장소를 자주 방문하여 쉬어가는 라이프 스타일을 가지고 있어요"
    
    private let gptUseCase: GPTUseCaseProtocol
    private let userUseCase: UserUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(gptUseCase: GPTUseCaseProtocol, userUseCase: UserUseCaseProtocol) {
        self.gptUseCase = gptUseCase
        self.userUseCase = userUseCase
    }
    
    func checkAndGeneratePersona(visitedPlace: [String], user: User) -> AnyPublisher<Void, Never> {
        guard visitedPlace.count > 10 else {
            print("ply 갯수 부족")
            return Just(()).eraseToAnyPublisher()
        }
        
        return gptUseCase.createPersonaNameAndDescription(from: visitedPlace)
            .flatMap { [weak self] result -> AnyPublisher<Void, Never> in
                guard let self = self else { return Just(()).eraseToAnyPublisher()}
                
                self.personaTitle = result.name
                self.personaDescription = result.description
                
                var updatedUser = user
                updatedUser.personaName = result.name
                updatedUser.personaDescription = result.description
                
                return self.userUseCase.saveUser(user: updatedUser)
                    .catch { error in
                        print("firebase에 저장 실패: \(error.localizedDescription)")
                        return Just(()).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .catch { error in
                print("GPT생성 실패: \(error.localizedDescription)")
                return Just(()).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
