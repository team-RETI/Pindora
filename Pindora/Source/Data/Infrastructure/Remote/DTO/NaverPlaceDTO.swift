//
//  NaverPlaceDTO.swift
//  Pindora
//
//  Created by 김동현 on 7/27/25.
//

import Foundation

// MARK: - Naver DTO
struct NaverPlaceDTO: Decodable {
    let placeName: String
    let placeAddress: String
    let mapX: String
    let mapY: String
    let category: String?
    
    enum CodingKeys: String, CodingKey {
        case placeName = "title"
        case placeAddress = "roadAddress"
        case mapX = "mapx"
        case mapY = "mapy"
        case category
    }
}

extension NaverPlaceDTO {
    func toPlace() -> Place? {
        guard let x = Double(mapX), let y = Double(mapY) else { return nil }
        
        let latitude = y / 1_000_000
        let longitude = x / 1_000_000
        let name = placeName.stripHTML()
        
        return Place(placeId: Place.generateId(name: name, latitude: latitude, longitude: longitude),
                     placeName: name,
                     placeAddress: placeAddress,
                     latitude: latitude,
                     longitude: longitude,
                     category: category ?? "기타",
                     addedDate: .now
        )
    }
}
