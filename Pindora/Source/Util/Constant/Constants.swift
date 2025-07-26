//
//  Constants.swift
//  Pindora
//
//  Created by 김동현 on 7/26/25.
//

import Foundation

enum Constants {
    enum NaverAPI {
        static let clientID = Bundle.main.infoDictionary?["NAVER_CLIENT_ID"] as? String ?? ""
        static let clientSecret = Bundle.main.infoDictionary?["NAVER_CLIENT_SECRET"] as? String ?? ""
        static let searchURL = "https://openapi.naver.com/v1/search/local.json"
    }
}
