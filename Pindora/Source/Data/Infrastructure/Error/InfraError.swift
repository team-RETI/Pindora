//
//  DBError.swift
//  Pindora
//
//  Created by 김동현 on 8/16/25.
//

import Foundation

// 인프라(Framework/SDK/네트워크 등)에러
enum InfraError: Error, LocalizedError, NestedError {
    
    // MARK: - Apple
    case appleInvalidCredential          // credential 캐스팅 실패
    case appleNonceMissing               // Nonce 누락
    case appleIDTokenParsingFailed       // idToken 파싱 실패
    case appleCanceled                   // 사용자가 로그인 UI에서 취소
    case appleError(Error)
    
    // MARK: - Firebase
    case firebaseError(Error)
    
    // MARK: - Location
    case locationAuthorizationDenied           // 설정에서 거부
    case locationAuthorizationRestricted       // 스크린타임/기관 제한 등
    case locationServicesDisabled              // 시스템 차원의 위치서비스 OFF
    case locationManagerError(Error)           // CLLocationManager 내부 에러 wrapping
    
    // MARK: - Search (Kakao API)
    case invalidURL
    case network(Error)
    case decoding(Error)
    
    // MARK: - Unknown
    case unknown(Error)
    
    var underlying: Error? {
        switch self {
        case .appleError(let e),
                .firebaseError(let e),
                .locationManagerError(let e),
                .unknown(let e):
            return e
        default:
            return nil
        }
    }
}

extension InfraError {
    var errorDescription: String? {
        String(describing: self._caseName)
    }
    
    /// enum 케이스 이름만 추출 (associated value 제외)
    private var _caseName: Any {
        switch self {
        case .appleInvalidCredential: return "🛠️ appleInvalidCredential"
        case .appleNonceMissing: return "🛠️ appleNonceMissing"
        case .appleIDTokenParsingFailed: return "🛠️ appleIDTokenParsingFailed"
        case .appleCanceled: return "🛠️ appleCanceled"
        case .unknown: return "🛠️ unknown"
        case .appleError: return "🛠️ appleError"
        case .firebaseError: return "🛠️ firebaseError"
        case .locationAuthorizationDenied: return "🛠️ locationAuthorizationDenied"
        case .locationAuthorizationRestricted: return "🛠️ locationAuthorizationRestricted"
        case .locationServicesDisabled: return "🛠️ locationServicesDisabled"
        case .locationManagerError: return "🛠️ locationManagerError"
        case .invalidURL: return "🛠️ invalidURL"
        case .decoding: return "🛠️ decodingError"
        case .network: return "🛠️ networkError"
        }
    }
}


