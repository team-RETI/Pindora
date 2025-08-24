//
//  DBError.swift
//  Pindora
//
//  Created by 김동현 on 8/16/25.
//

import Foundation

enum InfraError: Error, LocalizedError, NestedError {

    // MARK: - Apple
    case appleInvalidCredential          // credential 캐스팅 실패
    case appleNonceMissing               // Nonce 누락
    case appleIDTokenParsingFailed       // idToken 파싱 실패
    case appleCanceled                   // 사용자가 로그인 UI에서 취소
    case appleError(Error)
    
    // MARK: - Firebase
    case firebaseError(Error)
    
    // MARK: - Unknown
    case unknown(Error)
    
    var underlying: Error? {
        switch self {
        case .appleError(let e),
             .firebaseError(let e),
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
        }
    }
}


