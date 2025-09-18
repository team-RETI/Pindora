//
//  Constants.swift
//  Pindora
//
//  Created by 김동현 on 7/26/25.
//

import Foundation

enum Constants {
    enum NaverAPI {
        // 네이버 맵 SDK = ClientID, SecretID
        // 네이버 Open API = APIClientID, APISecretID
        // 네이버는 맵, API 두개가 다른 서비스이기에 하나의 ClientId, SecretId로 구현안되고 각각 필요함
        static let clientID = Bundle.main.infoDictionary?["NAVER_CLIENT_ID"] as? String ?? ""
        static let clientSecret = Bundle.main.infoDictionary?["NAVER_CLIENT_SECRET"] as? String ?? ""
        static let apiClientId = Bundle.main.infoDictionary?["NAVER_API_CLIENT_ID"] as? String ?? ""
        static let apiSecretId = Bundle.main.infoDictionary?["NAVER_API_SECRET_ID"] as? String ?? ""
        static let searchURL = "https://openapi.naver.com/v1/search/local.json"
    }
    
    enum KakaoAPI {
        static let restApiKey = Bundle.main.infoDictionary?["KAKAO_REST_API_KEY"] as? String ?? ""
    }
}

enum KakaoCategory: String, CaseIterable {
    case restaurant   = "FD6" // 음식점
    case cafe         = "CE7" // 카페
    case touristSpot  = "AT4" // 관광명소
    case cultural     = "CT1" // 문화시설(박물관/미술관)
    case publicOffice = "PO3" // 공공기관(도서관 등)

    var groupCode: String { rawValue }

    /// UI에 보여줄 한글 이름
    var displayName: String {
        switch self {
        case .restaurant:   return "식당"
        case .cafe:         return "카페"
        case .touristSpot:  return "관광지"
        case .cultural:     return "박물관"
        case .publicOffice: return "도서관"
        }
    }

    /// 한글 이름 -> enum (매칭 안 되면 nil)
    init?(displayName: String) {
        switch displayName {
        case "식당":   self = .restaurant
        case "카페":   self = .cafe
        case "관광지": self = .touristSpot
        case "박물관": self = .cultural
        case "도서관": self = .publicOffice
        default:       return nil
        }
    }
}
