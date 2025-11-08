//
//  PlaceUseCaseImpl.swift
//  Pindora
//
//  Created by 장주진 on 8/4/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class PlaceUseCaseImpl: PlaceUseCase {
    // MARK: - Dependencies
    private let repository: DatabaseRepositoryProtocol
    private let collection = "Places"

    // MARK: - State (SSOT)
    private let subject = CurrentValueSubject<[Place], Never>([])
    private var inFlight: AnyCancellable?
    private var lastFetchAt: Date?
    private let minInterval: TimeInterval = 5   // 최소 재호출 간격(초) - 상황에 맞게 조절
    private let syncQ = DispatchQueue(label: "place.usecase.sync") // 상태 보호용 직렬 큐
    
    // MARK: - Init
    init(repository: DatabaseRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Output
    func fetchPlaces() -> AnyPublisher<[Place], any Error> {
        repository.fetchAll(from: collection, as: PlaceDTO.self)
            .map { $0.map { $0.toEntity() } }
            .eraseToAnyPublisher()
    }
    
    func savePlace(place: Place) -> AnyPublisher<Void, UseCaseError> {
        guard let userId = Auth.auth().currentUser?.uid else {
            return Fail(error: UseCaseError.userNotFound).eraseToAnyPublisher()
        }

        let data = place.toDictionary()
        let userRef = Firestore.firestore().collection("Users").document(userId)

        return Future<Void, Error> { promise in
            userRef.updateData([
                "savedPlaces": FieldValue.arrayUnion([data])
            ]) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .mapToUseCaseError()
        .eraseToAnyPublisher()
    }
    
    func fetchKeywords() -> AnyPublisher<[String], Error> {
        repository.fetch(from: "Keywords", id: "Recommand", as: KeywordDTO.self)
            .map { $0.words }
            .eraseToAnyPublisher()
    }
    
    func fetchRecommendKeyword() -> AnyPublisher<[String], Error> {
        repository.fetch(from: "Keywords", id: "Register", as: RecommendKeywordDTO.self)
            .map { $0.keywords }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Smart Refresh (과호출/중복요청 방지)
    func refreshIfNeeded(force: Bool = false) {
        syncQ.async { [weak self] in
            guard let self else { return }

            // 1) 최소 간격 보장
            if !force, let last = self.lastFetchAt,
               Date().timeIntervalSince(last) < self.minInterval {
                return
            }

            // 2) 동일 요청 진행 중이면 병합
            if self.inFlight != nil {
                return
            }

            // 3) 실제 fetch 수행
            self.inFlight = self.fetchPlaces()
                .catch { [weak self] error -> Just<[Place]> in
                    // 실패 시 기존 값 유지
                    print("💥 refresh error:", error)
                    return Just(self?.subject.value ?? [])
                }
                .handleEvents(
                    receiveSubscription: { _ in print("📥 refresh start") },
                    receiveOutput: { [weak self] _ in self?.lastFetchAt = Date() },
                    receiveCompletion: { [weak self] completion in
                        print("📥 refresh completion:", completion)
                        // 완료 후 inFlight 해제
                        self?.syncQ.async { self?.inFlight = nil }
                    }
                )
                .sink { [weak self] newList in
                    self?.syncQ.async {
                        // 4) 중복 방출 방지(목록 동일 시 skip)
                        if let current = self?.subject.value,
                           current.count == newList.count,
                           zip(current, newList).allSatisfy({ $0.placeId == $1.placeId }) {
                            // 동일 → skip
                        } else {
                            self?.subject.send(newList)
                        }
                    }
                }
        }
    }
}
