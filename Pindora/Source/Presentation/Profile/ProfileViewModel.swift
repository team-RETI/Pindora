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
    
    struct Input {
        /// viewDidLoad 시 한 번 호출
        let viewDidLoad: AnyPublisher<Void, Never>
        /// 화면 복귀/강제 새로고침 트리거 (VC의 reloadSubject 연결)
        let reload: AnyPublisher<Void, Never>
    }
    
    struct Output {
        /// DB에 저장된 장소 리스트
        let places: AnyPublisher<[Place], Never>
        /// DB에 저장된 유저 정보
        let user: AnyPublisher<User?, Never>
    }
    
    func transform(input: Input) -> Output {
        // 최초 1회 + 이후 reload 트리거마다 fetch
        let reloadStream = Publishers.Merge(
            input.viewDidLoad,
            input.reload
        )
            .handleEvents(receiveOutput: { _ in
                print("🔄 reload trigger")
            })
        
        reloadStream
            .sink { [weak self] user in
                guard let uid = Auth.auth().currentUser?.uid else { return }
                self?.userUseCase.refreshIfNeeded(force: true, uid: uid)
            }
            .store(in: &cancellables)
        
        let user = userUseCase.userPublisher
            .eraseToAnyPublisher()
        
        let places = userUseCase.userPublisher
            .compactMap { $0?.visitedPlaces }
            .removeDuplicates(by: { lhs, rhs in
                guard lhs.count == rhs.count else { return false }
                // ID 비교가 가장 안전/빠름
                return zip(lhs, rhs).allSatisfy { $0.placeId == $1.placeId }
            })
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { print("✅ updated:", $0.count) })
            .eraseToAnyPublisher()
        
        return Output(
            places: places,
            user: user
        )
    }
    
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
