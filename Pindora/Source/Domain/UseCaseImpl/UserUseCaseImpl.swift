//
//  UserUseCaseImpl.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation
import Combine
import FirebaseFirestore

final class UserUseCaseImpl: UserUseCaseProtocol {
    // MARK: - Dependancies
    private let repository: DatabaseRepositoryProtocol
    private let collection = "Users"
    
    // MARK: - State (SSOT)
    private let subject = CurrentValueSubject<User?, Never>(nil)
    private var inFlight: AnyCancellable?
    private var lastFetchAt: Date?
    private let minInterval: TimeInterval = 5   // 최소 재호출 간격(초) - 상황에 맞게 조절
    private let syncQ = DispatchQueue(label: "user.usecase.sync") // 상태 보호용 직렬 큐
    
    init(repository: DatabaseRepositoryProtocol) {
        self.repository = repository
    }
    
    /// savedPlaces만 구독하고 싶을 때
    var savedPlacesPublisher: AnyPublisher<[Place], Never> {
        subject
            .compactMap { $0?.savedPlaces }
            .removeDuplicates(by: isSamePlaces)
            .eraseToAnyPublisher()
    }
    var placeLogPublisher: AnyPublisher<[Place], Never> {
        subject
            .compactMap { $0?.visitedPlaces }
            .eraseToAnyPublisher()
    }
    
    func saveUser(user: User) -> AnyPublisher<Void, UseCaseError> {
        let dto = user.toDTO()
        return repository.create(dto, at: collection, id: user.userId)
            .mapToUseCaseError()
            .eraseToAnyPublisher()
    }
    
    func fetchUser(uid: String) -> AnyPublisher<User, UseCaseError> {
        return repository
            .fetch(from: collection, id: uid, as: UserDTO.self)
            .map { $0.toEntity() }
            .mapError { _ in UseCaseError.userNotFound }
            .eraseToAnyPublisher()
    }
    
    func updateUser(user: User) -> AnyPublisher<Void, UseCaseError> {
        let dto = user.toDTO()
        return repository
            .update(dto, at: collection, id: user.userId)
            .mapToUseCaseError()
            .eraseToAnyPublisher()
    }
    
    func updateUserSavedPlaces(user: User, place: Place) -> AnyPublisher<Void, UseCaseError> {
        var updatedUser = user
        let exists = user.savedPlaces.contains { $0.placeId == place.placeId }
        
        if exists {
            updatedUser.savedPlaces.removeAll { $0.placeId == place.placeId }
        } else {
            updatedUser.savedPlaces.append(place)
        }
        
        return updateUser(user: updatedUser)
    }
    
    func updateUserPlaceLog(user: User, place: Place) -> AnyPublisher<Void, UseCaseError> {
        var updatedUser = user
        if let index = user.visitedPlaces.firstIndex(where: { $0.placeId == place.placeId }) {
            updatedUser.visitedPlaces.remove(at: index)
        }
        updatedUser.visitedPlaces.insert(place, at: 0)
        return updateUser(user: updatedUser)
    }
    
    func deleteUser(uid: String) -> AnyPublisher<Void, UseCaseError> {
        return repository.delete(from: collection, id: uid)
            .mapToUseCaseError()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Smart Refresh (과호출/중복요청 방지)
    /// 서버에서 User를 가져와 SSOT를 갱신. 실패 시 캐시 유지.
    func refreshIfNeeded(force: Bool = false, uid: String) {
        syncQ.async { [weak self] in
            guard let self else { return }

            // 1) 최소 간격 보장
            if !force, let last = self.lastFetchAt,
               Date().timeIntervalSince(last) < self.minInterval {
                return
            }

            // 2) 동일 요청 진행 중이면 병합
            if self.inFlight != nil { return }

            // 3) 실제 fetch 수행
            self.inFlight = self.fetchUser(uid: uid)
                .catch { [weak self] _ in
                    // 실패 시 캐시된 User? 를 User로 변환해서 방출 (nil이면 방출 안 함)
                    Just(self?.subject.value)
                        .compactMap { $0 }               // User? -> User
                        .eraseToAnyPublisher()           // <- Output: User, Failure: Never
                }
                .handleEvents(
                    receiveSubscription: { _ in print("📥 refresh start") },
                    receiveOutput: { [weak self] _ in self?.lastFetchAt = Date() },
                    receiveCompletion: { [weak self] completion in
                        print("📥 refresh completion:", completion)
                        self?.syncQ.async { self?.inFlight = nil }
                    }
                )
                .sink { [weak self] fetchedUser in
                    guard let self else { return }
                    self.syncQ.async {
                        // 현재 캐시가 없으면 바로 갱신
                        guard let current = self.subject.value else {
                            self.subject.send(fetchedUser)
                            print("here 1 ??")
                            return
                        }
                        // 캐시가 있으면 동일성 비교 후 변경 시에만 방출
//                        if self.isSameUser(current, fetchedUser) {
//                            // 동일 → skip
//                        } else {
                            self.subject.send(fetchedUser)
//                        }
                    }
                }
        }
    }
    
    private func isSameUser(_ a: User, _ b: User) -> Bool {
        a.userId == b.userId && isSamePlaces(a.visitedPlaces, b.visitedPlaces)
    }

    private func isSamePlaces(_ lhs: [Place], _ rhs: [Place]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        let la = Set(lhs.map { $0.placeId })
        let rb = Set(rhs.map { $0.placeId })

        return la == rb
    }
}

final class StubUserUsecaseImpl: UserUseCaseProtocol {
    private let repository: DatabaseRepositoryProtocol = DatabaseRepositoryImpl() // 실제 구현체 사용
    private let testUID = "f3BXGDk6b8eUWAU2xPPATH1honm1" // ✅ 고정 테스트 UID
    private let testSubject = CurrentValueSubject<User?, Never>(nil)
    init() {} // 매개변수 없이 생성 가능

    func saveUser(user: User) -> AnyPublisher<Void, UseCaseError> {
        // 여전히 더미 동작
        return Just(())
            .setFailureType(to: UseCaseError.self)
            .eraseToAnyPublisher()
    }

    func fetchUser(uid: String) -> AnyPublisher<User, UseCaseError> {
        return repository
            .fetch(from: "Users", id: testUID, as: UserDTO.self)
            .map { $0.toEntity() }
            .mapError { UseCaseError.map(from: $0 as! RepositoryError) }
            .eraseToAnyPublisher()
    }

    func updateUser(user: User) -> AnyPublisher<Void, UseCaseError> {
        return Just(())
            .setFailureType(to: UseCaseError.self)
            .eraseToAnyPublisher()
    }
    
    func updateUserSavedPlaces(user: User, place: Place) -> AnyPublisher<Void, UseCaseError> {
        return updateUser(user: user)
    }
    
    func updateUserPlaceLog(user: User, place: Place) -> AnyPublisher<Void, UseCaseError> {
        return updateUser(user: user)
    }
    
    func deleteUser(uid: String) -> AnyPublisher<Void, UseCaseError> {
        // 더미 성공 반환
        return Just(())
            .setFailureType(to: UseCaseError.self)
            .eraseToAnyPublisher()
    }
    
    var savedPlacesPublisher: AnyPublisher<[Place], Never> {
        testSubject
            .compactMap { $0?.savedPlaces }
            .eraseToAnyPublisher()
    }
    
    var placeLogPublisher: AnyPublisher<[Place], Never> {
        testSubject
            .compactMap { $0?.savedPlaces }
            .eraseToAnyPublisher()
    }
    
    func refreshIfNeeded(force: Bool, uid: String) {
        print("12")
    }
}

// .mapError { UseCaseError.map(from: $0 as! RepositoryError) }
extension Publisher where Failure == Error {
    func mapToUseCaseError() -> Publishers.MapError<Self, UseCaseError> {
        self.mapError { error in
            if let repo = error as? RepositoryError {
                return UseCaseError.map(from: repo)
            } else if let infra = error as? InfraError {
                return UseCaseError.map(from: RepositoryError.map(from: infra))
            } else {
                return .unknown(.unknown(.unknown(error)))
            }
        }
    }
}
