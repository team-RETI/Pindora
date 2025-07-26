//
//  NaverSearchAPIManagerTest.swift
//  ManagerTest
//
//  Created by 김동현 on 7/26/25.
//

import Foundation
import Combine
import Testing
@testable import Pindora

/*
 📌 이 파일은 네이버 장소 검색 API의 응답을 테스트하는 유닛 테스트입니다.
 
 ✅ Swift 5.9+에서 새롭게 도입된 매크로 기반 테스트 프레임워크인 `Testing`을 사용합니다.
 - 기존 XCTest 방식과 달리, `@Test("테스트 설명")`으로 테스트 이름을 명시할 수 있고
 - `async/await`를 자연스럽게 활용할 수 있어 비동기 로직 테스트에 유리합니다.
 - `#expect`를 통해 테스트 조건을 간결하게 표현할 수 있습니다.
 
 ✅ 이 테스트에서는 keyword를 검색했을 때, 유효한 장소 정보가 반환되는지를 검증합니다.
 */

enum TestError: Error {
    case placeIsNil
}

struct NaverSearchAPIManagerTest {
    
    @Test("네이버 검색 API @escaping 테스트")
    func test_naverAPI_escaping() async throws {
        let manager = NaverSearchAPIManager.shared
        
        // 비동기 awaitable 형태로 변환 필요
        let place = try await withCheckedThrowingContinuation { continuation in
            manager.searchEscaping(keyword: "마초스테이크 부산") { result in
                if let place = result {
                    continuation.resume(returning: place)
                } else {
                    continuation.resume(throwing: TestError.placeIsNil)
                }
            }
        }
        
        // 검증
        #expect(!place.name.isEmpty)
        #expect(!place.address.isEmpty)
        print("🟦 [Escaping API 결과]")
        print("✅ 검색어: \("마초스테이크 부산")")
        print("✅ 이름: \(place.name)")
        print("✅ 주소: \(place.address)")
        print("✅ 위도: \(place.latitude)")
        print("✅ 경도: \(place.longitude)")
    }
    
    @Test("네이버 검색 API Combine 테스트")
    func test_naverAPI_combine() async throws {
        let manager = NaverSearchAPIManager.shared
        let keyword = "마초스테이크 부산"
        
        var cancellable: AnyCancellable?
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            cancellable = manager.searh(keyword: keyword)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: { place in
                    guard let place else {
                        continuation.resume(throwing: TestError.placeIsNil)
                        return
                    }
                    
                    // 검증
                    #expect(!place.name.isEmpty)
                    #expect(!place.address.isEmpty)
                    print("🟦 [Combine API 결과]")
                    print("✅ 검색어: \("마초스테이크 부산")")
                    print("✅ 이름: \(place.name)")
                    print("✅ 주소: \(place.address)")
                    print("✅ 위도: \(place.latitude)")
                    print("✅ 경도: \(place.longitude)")
                    
                    continuation.resume() // Void 리턴
                })
            // cancellable을 범위 내에서 유지
            withExtendedLifetime(cancellable) {}
        }
    }
}
