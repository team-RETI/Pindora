////
////  FirebaseDatabaseManager_CombineTests.swift
////  ManagerTest
////
////  Created by 김동현 on 2025/08/16
////
//
//import Foundation
//import Combine
//import Testing
//import FirebaseCore
//@preconcurrency import FirebaseFirestore
//@testable import Pindora
//
//// MARK: - 모델 정의
//struct TestUser: Codable, Equatable {
//    var userId: String
//    var name: String
//    var age: Int
//}
//
//// MARK: - Firestore 설정 및 초기화
//enum FBCTestBoot {
//    private static var didConfig = false
//
//    static func boot() {
//        guard !didConfig else { return }
//
//        if FirebaseApp.app() == nil {
//            let opts = FirebaseOptions(
//                googleAppID: "1:111111111111:ios:1111111111111111",
//                gcmSenderID: "111111111111"
//            )
//            opts.projectID = "demo-test-project"
//            FirebaseApp.configure(options: opts)
//        }
//
//        let db = Firestore.firestore()
//        #if targetEnvironment(simulator)
//        db.useEmulator(withHost: "127.0.0.1", port: 8080)
//        #else
//        db.useEmulator(withHost: "192.168.0.12", port: 8080)
//        #endif
//
//        var settings = db.settings
//        settings.isSSLEnabled = false
//        db.settings = settings
//
//        didConfig = true
//    }
//
//    static func clean(_ collection: String) async {
//        let db = Firestore.firestore()
//        await withCheckedContinuation { cont in
//            db.collection(collection).getDocuments { snap, _ in
//                let batch = db.batch()
//                snap?.documents.forEach { batch.deleteDocument($0.reference) }
//                batch.commit { _ in cont.resume() }
//            }
//        }
//    }
//}
//
//// MARK: - Combine helper (Publisher → async)
//func awaitPublisher<T: Publisher>(_ publisher: T) async throws -> T.Output {
//    try await withCheckedThrowingContinuation { continuation in
//        var cancellable: AnyCancellable?
//        cancellable = publisher
//            .sink(receiveCompletion: { completion in
//                if case let .failure(error) = completion {
//                    continuation.resume(throwing: error)
//                }
//                cancellable?.cancel()
//            }, receiveValue: { value in
//                continuation.resume(returning: value)
//                cancellable?.cancel()
//            })
//    }
//}
//
//// MARK: - Combine 기반 CRUD 테스트
//@Suite("FirebaseDatabaseManager / Combine Generic CRUD")
//struct FirebaseDatabaseManager_Combine_Tests {
//    let manager = FirebaseDatabaseManager.shared
//    let collection = "Users_Test_Combine"
//    
//    @Test("Combine 기반: Create → Read → Update → Read → Delete → Read(에러)")
//    func test_combine_crud() async {
//        FBCTestBoot.boot()
//        await FBCTestBoot.clean(collection)
//
//        let uid = "u_\(UUID().uuidString.prefix(8))"
//        let createUser = TestUser(userId: uid, name: "Alice", age: 20)
//        let updatedUser = TestUser(userId: uid, name: "Alicia", age: 21)
//
//        // 1. Create
//        do {
//            try await awaitPublisher(
//                manager.createGenericPublisher(collection: collection, documentID: uid, object: createUser)
//            )
//        } catch {
//            Issue.record("❌ Create 실패: \(error)")
//        }
//
//        // 2. Read
//        do {
//            let user = try await awaitPublisher(
//                manager.readGenericPublisher(collection: collection, documentID: uid, as: TestUser.self)
//            )
//            #expect(user == createUser)
//        } catch {
//            Issue.record("❌ Read(1) 실패: \(error)")
//        }
//
//        // 3. Update
//        do {
//            try await awaitPublisher(
//                manager.updateGenericPublisher(collection: collection, documentID: uid, with: updatedUser)
//            )
//        } catch {
//            Issue.record("❌ Update 실패: \(error)")
//        }
//
//        // 4. Read (updated)
//        do {
//            let user = try await awaitPublisher(
//                manager.readGenericPublisher(collection: collection, documentID: uid, as: TestUser.self)
//            )
//            #expect(user == updatedUser)
//        } catch {
//            Issue.record("❌ Read(2) 실패: \(error)")
//        }
//
//        // 5. Delete
//        do {
//            try await awaitPublisher(
//                manager.deleteGenericPublisher(collection: collection, documentID: uid)
//            )
//        } catch {
//            Issue.record("❌ Delete 실패: \(error)")
//        }
//
//        // 6. Read (after delete → 실패 기대)
//        do {
//            let _: TestUser = try await awaitPublisher(
//                manager.readGenericPublisher(collection: collection, documentID: uid, as: TestUser.self)
//            )
//            Issue.record("❌ 삭제 후에도 Read가 성공해버렸습니다 (실패 기대)")
//        } catch {
//            let ns = error as NSError
//            #expect(ns.domain == "FirestoreError")
//            #expect(ns.code == -1)
//            #expect((ns.userInfo[NSLocalizedDescriptionKey] as? String) == "문서를 찾을 수 없습니다.")
//        }
//    }
//}
