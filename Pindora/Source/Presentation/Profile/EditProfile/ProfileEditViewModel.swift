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
    
    var selectedImageType: ImageType = .custom
    var selectedColor: UIColor?
    var personaTitle: String = "즉흥적인 도시 탐험가"
    var personaDescription: String = "조용한 카페를 선호하고 갑작스럽게 화장실을 자주가며 고즈넉한 장소를 자주 방문하여 쉬어가는 라이프 스타일을 가지고 있어요"
    
    // DI
    private let imageUseCase: ImageUsecaseProtocol   // Firebase Storage 업로드용
    private let userUseCase: UserUseCaseProtocol     // Firestore 저장용
    private var cancellables = Set<AnyCancellable>()
    
    // 저장 중 표시용 (UI 바인딩 가능)
    @Published var isSaving = false
    @Published var saveError: String?
    
    init(imageUseCase: ImageUsecaseProtocol, userUseCase: UserUseCaseProtocol) {
        self.imageUseCase = imageUseCase
        self.userUseCase = userUseCase
    }
    
    func registerProfile(user: User, customImage: UIImage?) -> AnyPublisher<Void, Never> {
        isSaving = true
        saveError = nil
        
        let uploadPublisher: AnyPublisher<String?, Never>
        
        switch selectedImageType {
        case .custom:
            if let img = customImage {
                uploadPublisher = imageUseCase.upload(
                    image: img,
                    folder: "UserImage/\(user.userId)",
                    fileName: UUID().uuidString
                )
                .map { $0.absoluteString }
                .map { Optional($0) }
                .catch { [weak self] error -> Just<String?> in
                    self?.saveError = "이미지 업로드 실패: \(error.localizedDescription)"
                    return Just(nil)
                }
                .eraseToAnyPublisher()
            } else {
                uploadPublisher = Just(nil).eraseToAnyPublisher()
            }
            
        case .color:
            if let color = selectedColor {
                let img = UIImage.fromColor(color)
                uploadPublisher = imageUseCase.upload(
                    image: img,
                    folder: "UserImage/\(user.userId)",
                    fileName: UUID().uuidString
                )
                .map { $0.absoluteString }
                .map { Optional($0) }
                .catch { [weak self] error -> Just<String?> in
                    self?.saveError = "컬러 이미지 업로드 실패: \(error.localizedDescription)"
                    return Just(nil)
                }
                .eraseToAnyPublisher()
            } else {
                uploadPublisher = Just(nil).eraseToAnyPublisher()
            }
            
        case .memoji:
            uploadPublisher = Just(nil).eraseToAnyPublisher()
        }
        
        // 이후 Firestore 저장은 동일
        return uploadPublisher
            .flatMap { [weak self] imageURL -> AnyPublisher<Void, Never> in
                guard let self = self else { return Just(()).eraseToAnyPublisher() }
                
                var updated = user
                if let url = imageURL {
                    updated.userImage = url
                }
                updated.personaName = self.personaTitle
                updated.personaDescription = self.personaDescription
                
                return self.userUseCase.saveUser(user: updated)
                    .map { }
                    .catch { [weak self] error -> Just<Void> in
                        self?.saveError = "프로필 저장 실패: \(error.localizedDescription)"
                        return Just(())
                    }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isSaving = false
            },
                          receiveCompletion: { [weak self] _ in
                self?.isSaving = false
            })
            .eraseToAnyPublisher()
    }
}
