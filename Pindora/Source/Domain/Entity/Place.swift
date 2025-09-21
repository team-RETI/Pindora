//
//  Place.swift
//  Pindora
//
//  Created by 김동현 on 7/26/25.
//

import Foundation
import CoreLocation
import CryptoKit

// MARK: - 현재 Naver API에서 필수적으로 들어오는 속성만 작성해두었습니다. 추가적인 속성은 옵셔널로 해주세요
/// 외부 장소 검색 API에서 가져온 장소 정보를 나타내는 모델입니다.
/// Hashable: 장소의 비교 및 Set/Dictionary에서 사용 가능하도록 함
/// Identifiable: SwiftUI List 등의 View에서 고유 식별자 제공 시 사용
struct Place: Hashable {
    var placeId: String         // 장소 고유 식별자
    let placeName: String       // 장소 이름
    let placeAddress: String    // 도로명 주소
    let latitude: Double        // 위도
    let longitude: Double       // 경도
    let category: String        // 카테고리(음식점, 카페)
    let addedDate: Date         // 추가된 날짜
    
    // 옵셔널 속성들
    var likedCount: Int?        // 좋아요
    var naviLink: String?       // 장소링크
    var instaLink: String?      // 인스타링크
    var bookLink: String?       // 예약링크
    var imageURL: String?       // 대표이미지(Storage주소)
}

// MARK: - DTO로 변환
extension Place {
    func toDTO() -> PlaceDTO {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: addedDate)

        return PlaceDTO(
            placeId: placeId,
            placeName: placeName,
            placeAddress: placeAddress,
            latitude: latitude,
            longitude: longitude,
            category: category,
            addedDate: dateString,
            likedCount: likedCount,
            naviLink: naviLink,
            instaLink: instaLink,
            bookLink: bookLink,
            imageURL: imageURL
        )
    }
}

// MARK: - 고유 Id 생성
extension Place {
    
    /// 입력된 문자열로부터 SHA256 해시값을 생성하여 반환합니다.
    ///
    /// 원래는 `UUID().uuidString`을 사용해 고유 ID를 생성하려 했으나,
    /// 사용자가 이미 추가한 장소를 중복 저장하지 않도록 하기 위해,
    /// 장소 이름과 좌표 기반으로 고정된 해시값을 생성합니다.
    ///
    /// 같은 장소에 대해 항상 동일한 ID가 생성되므로,
    /// Firestore 등에서 중복 저장을 방지할 수 있습니다.
    ///
    /// - Parameter input: 해시를 생성할 대상 문자열 (예: "스타벅스_35.12345_129.12345")
    /// - Returns: SHA256 해시값을 16진수 문자열로 인코딩한 값
    static func sHA256String(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// 장소 이름과 좌표를 기반으로 고유 ID를 생성합니다.
    ///
    /// - Parameters:
    ///   - name: 장소 이름
    ///   - latitude: 위도
    ///   - longitude: 경도
    /// - Returns: 생성된 고유 ID 문자열
    static func generateId(name: String, latitude: Double, longitude: Double) -> String {
        let roundedLat = String(format: "%.5f", latitude)
        let roundedLng = String(format: "%.5f", longitude)
        let base = Place.sHA256String("\(name)_\(roundedLat)_\(roundedLng)")
        return base
    }
}

// MARK: - Stub data
extension Place {
    /// 스텁 테스트용 예시 데이터입니다.
    static let stubPlace = Place(
        placeId: "스타벅스_35.12345_129.12345",
        placeName: "스타벅스 서면점",
        placeAddress: "부산 부산진구 서면로...",
        latitude: 35.12345,
        longitude: 129.12345,
        category: "카페",
        addedDate: .now
    )
    
    /// 테스트용 임의 장소 데이터를 생성합니다.
    ///
    /// - Parameters:
    ///   - name: 장소 이름 (기본값: "샘플 장소")
    ///   - address: 장소 주소 (기본값: "서울특별시 어딘가")
    ///   - latitude: 위도 (기본값: 37.5665)
    ///   - longitude: 경도 (기본값: 126.9780)
    ///   - category: 장소 카테고리 (기본값: "카페")
    /// - Returns: `Place` 객체. 이름과 좌표 기반으로 생성된 `placeId`를 포함합니다.
    static func dummy(
        name: String = "샘플 장소",
        address: String = "서울특별시 어딘가",
        latitude: Double = 37.5665,
        longitude: Double = 126.9780,
        category: String = "카페"
    ) -> Place {
        let id = generateId(name: name, latitude: latitude, longitude: longitude)
        return Place(
            placeId: id,
            placeName: name,
            placeAddress: address,
            latitude: latitude,
            longitude: longitude,
            category: category,
            addedDate: Date.from(year: 2025, month: 5, day: 5)
        )
    }
}

// MARK: - 날짜 생성
extension Date {
    
    /// 주어진 연, 월, 일로 구성된 고정 날짜를 생성합니다.
    ///
    /// - Parameters:
    ///   - year: 연도 (예: 2025)
    ///   - month: 월 (1~12)
    ///   - day: 일 (1~31)
    /// - Returns: 생성된 `Date`, 실패 시 현재 시간 반환
    static func from(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(calendar: Calendar.current, year: year, month: month, day: day)
        return components.date ?? Date()
    }
}

// MARK: - 현재 위치와 장소 사이의 거리 측정
extension Place {
    
    /// 디버깅이나 로그용 설명 텍스트
    var description: String {
        """
        📍 \(placeName)
        🏠 \(placeAddress)
        🗺️ 위도: \(latitude), 경도: \(longitude)
        📂 카테고리: \(category)
        🆔 ID: \(placeId)
        """
    }
    
    /// 지정된 위치와 현재 장소 간의 거리를 반환합니다.
    ///
    /// - Parameter location: 비교할 기준 위치 (`CLLocation`)
    /// - Returns: 기준 위치로부터 현재 장소까지의 거리 (미터 단위)
    func distance(from location: CLLocation) -> CLLocationDistance {
        let placeLocation = CLLocation(latitude: latitude, longitude: longitude)
        return placeLocation.distance(from: location)
    }
}

// MARK: - Diffable(부드럽고 안정적인 업데이트) 확장용
extension Place {
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.placeId == rhs.placeId
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(placeId)
    }
    
    // Snapshot : Diffable은 Section → Items 구조라, Section을 먼저 정의
    enum PlaceSection {
        case main
    }
}
