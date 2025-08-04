//
//  PlaceDTO.swift
//  Pindora
//
//  Created by 김동현 on 7/27/25.
//

import Foundation

struct PlaceDTO: Codable {
    let placeId: String
    let placeName: String
    let placeAddress: String
    let latitude: Double
    let longitude: Double
    let category: String
    let addedDate: String
    
    let likedCount: Int?
    let naviLink: String?
    let instaLink: String?
    let bookLink: String?
    let imageURL: String?
}

// MARK: - Entity로 변환
extension PlaceDTO {
    /// DTO → Domain(Entity) 변환
    func toEntity() -> Place {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: addedDate) ?? Date.from(year: 2000, month: 1, day: 1) // 파싱 실패 시 로그 시간
        
        return Place(
            placeId: placeId,
            placeName: placeName,
            placeAddress: placeAddress,
            latitude: latitude,
            longitude: longitude,
            category: category,
            addedDate: date,
            likedCount: likedCount,
            naviLink: naviLink,
            instaLink: instaLink,
            bookLink: bookLink,
            imageURL: imageURL
        )
    }
}
