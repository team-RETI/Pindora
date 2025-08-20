//
//  RepositoryError.swift
//  Pindora
//
//  Created by 김동현 on 8/18/25.
//

import Foundation

// 개발적 친화적 멘트
enum RepositoryError: Error, NestedError, LocalizedError {
    
    // MARK: - 공통 Error
    case appleInvalidCredential(InfraError)
    case appleNonceMissing(InfraError)
    case appleIDTokenParsingFailed(InfraError)
    case appleCanceled(InfraError)
    case appleError(InfraError)
    
    case firebaseError(InfraError)
    
    case unknown(InfraError)

    // MARK: - NestedError
    var underlying: Error? {
        switch self {
        case .appleInvalidCredential(let e),
             .appleNonceMissing(let e),
             .appleIDTokenParsingFailed(let e),
             .appleCanceled(let e),
             .unknown(let e),
             .appleError(let e),
             .firebaseError(let e):
            return e

        }
    }

    // MARK: - Developer-Friendly Description
    var errorDescription: String? {
        switch self {
        case .appleInvalidCredential: return "📦 [Apple 인증 실패] - 자격 증명이 유효하지 않음"
        case .appleNonceMissing: return "📦 [Apple 인증 실패] - nonce가 누락됨"
        case .appleIDTokenParsingFailed: return "📦 [Apple 인증 실패] - ID Token 파싱 실패"
        case .appleCanceled: return "📦 [Apple 인증 실패] - 사용자가 인증을 취소함"
        case .unknown(let e): return "📦 [알 수 없는 오류] - \(e.localizedDescription)"
        case .appleError:    return "📦 [Apple 에러] - FirebaseAuthManager를 확인해주세요"
        case .firebaseError: return "📦 [Firebase 에러] - Firebase 관련 Manager를 확인해주세요."
        }
    }

    // MARK: - Mapping
    static func map(from error: InfraError) -> RepositoryError {
        switch error {
        case .appleInvalidCredential: return .appleInvalidCredential(error)
        case .appleNonceMissing: return .appleNonceMissing(error)
        case .appleIDTokenParsingFailed: return .appleIDTokenParsingFailed(error)
        case .appleCanceled: return .appleCanceled(error)
        case .appleError: return .appleError(error)
        case .firebaseError: return .firebaseError(error)
        case .unknown: return .unknown(error)
        }
    }
}
