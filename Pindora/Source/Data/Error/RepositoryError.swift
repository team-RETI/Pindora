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
    
    case locationAuthorizationDenied(InfraError)
    case locationAuthorizationRestricted(InfraError)
    case locationServicesDisabled(InfraError)
    case locationManagerError(InfraError)
    
    case invalidURL(InfraError)
    case network(InfraError)
    case decoding(InfraError)
    
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
                .locationAuthorizationDenied(let e),
                .locationAuthorizationRestricted(let e),
                .locationServicesDisabled(let e),
                .locationManagerError(let e),
                .invalidURL(let e),
                .network(let e),
                .decoding(let e),
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
        case .appleError:    return "📦 [Apple 에러] - FirebaseAuthManager를 확인해주세요"
        case .firebaseError: return "📦 [Firebase 에러] - Firebase 관련 Manager를 확인해주세요."
        case .locationAuthorizationDenied: return "📦 [Location 권한 거부] - GPS 권한이 거부되었습니다"
        case .locationAuthorizationRestricted: return "📦 [Location 권한 제한] - GPS 권한 제한되었습니다"
        case .locationServicesDisabled: return "📦 [Location OFF] - 시스템 위치 서비스가 꺼져있습니다"
        case .locationManagerError: return "📦 [Location 에러] Manager 오류"
        case .invalidURL: return "📦 [외부 API URL 파싱 실패] - URL이 유효하지 않음"
        case .network: return "📦 [외부 API 네트워크 에러] - 네트워크 연결이 끊겼습니다"
        case .decoding: return "📦 [외부 API 디코딩 에러] - 데이터 디코딩에 실패했습니다"
        case .unknown(let e): return "📦 [알 수 없는 오류] - \(e.localizedDescription)"
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
        case .locationAuthorizationDenied: return .locationAuthorizationDenied(error)
        case .locationAuthorizationRestricted: return .locationAuthorizationRestricted(error)
        case .locationServicesDisabled: return .locationServicesDisabled(error)
        case .locationManagerError: return .locationManagerError(error)
        case .invalidURL: return .invalidURL(error)
        case .network: return .network(error)
        case .decoding: return .decoding(error)
        case .unknown: return .unknown(error)
        }
    }
}
