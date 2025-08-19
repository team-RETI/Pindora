//
//  DBError.swift
//  Pindora
//
//  Created by 김동현 on 8/16/25.
//

import Foundation

// 프레임워크/SDK에서 발생한 오류를 그대로 감싸는 열거형
enum InfraError: Error, NestedError {
    // MARK: - Common
    case timeout            // 요청 시간 초과
    case networkUnavailable // 네트워크 연결 불가
    case permissionDenied   // 권한 없음
    case unknown(Error)     // 그 외의 에러
    
    // MARK: - Apple
    case appleInvalidCredential          // credential 캐스팅 실패
    case appleNonceMissing               // Nonce 누락
    case appleIDTokenParsingFailed       // idToken 파싱 실패
    case appleCanceled                   // 사용자가 로그인 UI에서 취소
    case appleUnknown(Error)
    
    // MARK: - Firebase SDK 내부 오류는 종류가 많고 예측 불가하므로 원본 에러를 그대로 매핑
    case firebaseUnknown(Error)
    
    // MARK: - Kakao
}

extension InfraError: LocalizedError {
    public var errorDescription: String? {
        switch self {
            
        // MARK: - Common
        case .timeout:
            return "요청이 시간 내에 완료되지 않았습니다. 네트워크 상태를 확인해주세요."
        case .networkUnavailable:
            return "네트워크에 연결할 수 없습니다. 인터넷 상태를 확인해주세요."
        case .permissionDenied:
            return "이 작업을 수행할 수 있는 권한이 없습니다."
            
        // MARK: - Apple
        case .appleInvalidCredential:
            return "유효하지 않은 Apple 자격 증명입니다."
        case .appleNonceMissing:
            return "보안 토큰(nonce)이 누락되었습니다. 다시 시도해주세요."
        case .appleIDTokenParsingFailed:
            return "Apple ID 토큰을 처리할 수 없습니다."
        case .appleCanceled:
            return "사용자가 로그인 과정을 취소했습니다."
            
        // MARK: - Unknown
        case .firebaseUnknown(let error):
            return "[FirebaseUnknown Unknown] \(error.localizedDescription)"
        case .appleUnknown(let error):
            return "[Apple Unknown] \(error.localizedDescription)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

extension InfraError {
    var underlying: Error? {
        switch self {
        case .unknown(let error):        return error
        default:                         return nil
        }
    }
}



