//
//  kakaoDTO.swift
//  Pindora
//
//  Created by eunchanKim on 9/17/25.
//

import Foundation

struct KakaoGeoCodeDTO: Decodable {
    let address_name: String
    let address_type: String
    let x: String
    let y: String
    let address: Address?
    let roadAddress: RoadAddress?
}

struct Address: Decodable {
    let address_name: String
    let x: String
    let y: String
}

struct RoadAddress: Decodable {
    let address_name: String
    let building_name: String
    let x: String
    let y: String
}

extension KakaoGeoCodeDTO {
    func toPlace() -> Place? {
        guard let x = Double(x), let y = Double(y) else { return nil }
        let name = roadAddress?.building_name ?? address_name
        let latitude = y
        let longitude = x

        return Place(placeId: Place.generateId(name: address_name, latitude: latitude, longitude: longitude),
                     placeName: name,
                     placeAddress: address_name,
                     latitude: latitude,
                     longitude: longitude,
                     category: "",
                     addedDate: .now
        )
    }
}
