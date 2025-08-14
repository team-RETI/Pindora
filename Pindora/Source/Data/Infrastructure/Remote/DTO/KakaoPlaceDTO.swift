//
//  KakaoPlaceDTO.swift
//  Pindora
//
//  Created by eunchanKim on 8/12/25.
//

import Foundation

// MARK: - Kakao DTO
/* KakaoAPI 에서는 ID값을 결과로 주지만 따로 만들어서 관리하기 위해 ID값은 제외*/
struct KakaoPlaceDTO: Decodable {
    let place_name: String
    let road_address_name: String
    let x: String
    let y: String
    let category_name: String? //예시 ("의료,건강 > 약국")
    
    /* 옵션 사항 */
    let category_group_code: String? //중요 카테고리만 그룹핑한 카테고리 그룹코드 예시(PM9)
    let category_group_name: String? //중요 카테고리만 그룹핑한 카테고리 그룹명 예시(약국)
    let distance: String? //중심좌표까지의 거리(m)
    let phone: String? //전화번호
    let place_url: String? //장소 상세 페이지 URL
}

extension KakaoPlaceDTO {
    func toPlace() -> Place? {
        guard let x = Double(x), let y = Double(y) else { return nil }
        
        /* Kakao API는 x,y 좌표가 소수형태로 받아옴 예시 ("x": "127.05897078335246", "y": "37.506051888130386") */
        let latitude = y
        let longitude = x
        let name = place_name
        
        return Place(placeId: Place.generateId(name: name, latitude: latitude, longitude: longitude),
                     placeName: name,
                     placeAddress: road_address_name,
                     latitude: latitude,
                     longitude: longitude,
                     category: category_name ?? "기타",
                     addedDate: .now
        )
    }
}
