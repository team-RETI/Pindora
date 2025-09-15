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

enum KakaoCategoryGroup: String, CaseIterable {
    case MT1, CS2, PS3, SC4, AC5, PK6, OL7, SW8, BK9
    case CT1, AG2, PO3, AT4, AD5, FD6, CE7, HP8, PM9
    case ETC

    var displayName: String {
        switch self {
        case .MT1: return "대형마트"
        case .CS2: return "편의점"
        case .PS3: return "어린이집, 유치원"
        case .SC4: return "학교"
        case .AC5: return "학원"
        case .PK6: return "주차장"
        case .OL7: return "주유소, 충전소"
        case .SW8: return "지하철역"
        case .BK9: return "은행"
        case .CT1: return "문화시설"
        case .AG2: return "중개업소"
        case .PO3: return "공공기관"
        case .AT4: return "관광명소"
        case .AD5: return "숙박"
        case .FD6: return "음식점"
        case .CE7: return "카페"
        case .HP8: return "병원"
        case .PM9: return "약국"
        case .ETC: return "기타"
        }
    }
    /// 에셋(Assets)에서 사용할 기본 이미지 이름을 규약으로 지정
    /// 예: "cat_CE7", "cat_FD6" 처럼 만들어 두면 유지보수 편함
    var assetName: String {
        switch self {
        case .ETC: return "\(rawValue)"
        default:   return "\(rawValue)"
        }
    }
    
    /// 표시 이름 → 그룹 코드 (역매핑)
    static func from(displayName: String) -> KakaoCategoryGroup? {
        return Self.allCases.first { $0.displayName == displayName }
    }
}

struct CategoryResolver {
    /// 카카오 그룹코드가 없을 때, category_name으로 추론
    static func inferGroup(from categoryName: String) -> KakaoCategoryGroup {
        let lower = categoryName.lowercased()

        // 자주 쓰는 키워드들 (필요 시 계속 보강)
        if lower.contains("카페") || lower.contains("coffee") { return .CE7 }
        if lower.contains("음식") || lower.contains("식당")
            || lower.contains("분식") || lower.contains("한식")
            || lower.contains("일식") || lower.contains("중식")
            || lower.contains("양식") || lower.contains("치킨")
            || lower.contains("피자") || lower.contains("버거")
            || lower.contains("족발") || lower.contains("보쌈")
            || lower.contains("초밥") || lower.contains("라멘")
        { return .FD6 }

        if lower.contains("병원") || lower.contains("의원")
            || lower.contains("내과") || lower.contains("치과")
            || lower.contains("한의원") || lower.contains("피부과")
        { return .HP8 }

        if lower.contains("약국") || lower.contains("pharmacy") { return .PM9 }

        if lower.contains("편의점") || lower.contains("convenience") { return .CS2 }

        if lower.contains("마트") { return .MT1 }

        if lower.contains("주유") || lower.contains("충전소") || lower.contains("gas") { return .OL7 }

        if lower.contains("주차장") || lower.contains("parking") { return .PK6 }

        if lower.contains("은행") || lower.contains("atm") { return .BK9 }

        if lower.contains("지하철") || lower.contains("역") { return .SW8 }

        if lower.contains("숙박") || lower.contains("호텔") || lower.contains("모텔") || lower.contains("게스트하우스") { return .AD5 }

        if lower.contains("관광") || lower.contains("명소") || lower.contains("전망대") { return .AT4 }

        if lower.contains("학교") || lower.contains("초등") || lower.contains("중학") || lower.contains("고등") || lower.contains("대학교") { return .SC4 }

        if lower.contains("학원") { return .AC5 }

        if lower.contains("문화") || lower.contains("박물관") || lower.contains("미술관") || lower.contains("도서관") { return .CT1 }

        if lower.contains("공공") || lower.contains("구청") || lower.contains("시청") || lower.contains("주민센터") { return .PO3 }

        if lower.contains("부동산") || lower.contains("중개") { return .AG2 }

        // 매칭 실패 → 기타
        return .ETC
    }

    /// 코드 문자열이 유효하면 그대로, 없으면 이름 기반 추론
    static func resolve(code: String?, categoryName: String?) -> KakaoCategoryGroup {
        if let code, let g = KakaoCategoryGroup(rawValue: code) { return g }
        if let name = categoryName, name.isEmpty == false {
            return inferGroup(from: name)
        }
        return .ETC
    }
}

extension KakaoPlaceDTO {
    func toPlace() -> Place? {
        guard let x = Double(x), let y = Double(y) else { return nil }
        
        /* Kakao API는 x,y 좌표가 소수형태로 받아옴 예시 ("x": "127.05897078335246", "y": "37.506051888130386") */
        let latitude = y
        let longitude = x
        let name = place_name
        // 카테고리 그룹이 없을 경우를 대비해 카테고리이름으로 코드 매핑
        let group = CategoryResolver.resolve(code: category_group_code, categoryName: category_name)
        // 이름으로 매핑한 코드를 이용해서 카테고리로 반환
        let category = categoryName(for: group.assetName) ?? ""
        return Place(placeId: Place.generateId(name: name, latitude: latitude, longitude: longitude),
                     placeName: name,
                     placeAddress: road_address_name,
                     latitude: latitude,
                     longitude: longitude,
                     category: category,
                     addedDate: .now
        )
    }
    
    func categoryName(for code: String) -> String? {
        return KakaoCategoryGroup(rawValue: code)?.displayName
    }
    
}
