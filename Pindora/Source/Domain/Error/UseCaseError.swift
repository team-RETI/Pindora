//
//  ServiceError.swift
//  Pindora
//
//  Created by 김동현 on 8/17/25.
//

import Foundation

// 사용자 친화적 멘트
protocol NestedError: Error {
    /// 에러 체이닝(원인 추적)을 위한 프로토콜입니다
    ///
    /// 하나의 에러가 다른 에러를 감싸고 있을 경우(`wrap`),
    /// 최종적으로 어떤 에러가 발생했는지 계층적으로 추적할 수 있게 도와줍니다.
    ///
    /// 예를 들어, UseCaseError가 RepositoryError를 감싸고,
    /// RepositoryError가 InfraError를 감쌌다면,
    /// `underlying`을 따라가며 전체 에러 흐름을 추적할 수 있습니다.
    var underlying: Error? { get }
}

// MARK: - UseCaseError
enum UseCaseError: Error, NestedError, LocalizedError {
    
    // MARK: - 일반 유즈케이스 에러
    case invalidState
    case userNotFound
    
    // MARK: - 공통 Error
    case appleInvalidCredential(RepositoryError)
    case appleNonceMissing(RepositoryError)
    case appleIDTokenParsingFailed(RepositoryError)
    case appleCanceled(RepositoryError)
    case appleError(RepositoryError)
    
    case firebaseError(RepositoryError)
    
    case unknown(RepositoryError)
    

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
        case .invalidState, .userNotFound:
            return nil
        }
    }

    // MARK: - User-facing Error Description
    var errorDescription: String? {
        switch self {
        case .invalidState:
            return "⚠️ 잘못된 요청 상태입니다."
        case .userNotFound:
            return "⚠️ 사용자를 찾을 수 없습니다."
        case .appleInvalidCredential:
            return "⚠️ 애플 인증 자격이 유효하지 않습니다."
        case .appleNonceMissing:
            return "⚠️ 인증 nonce가 누락되었습니다."
        case .appleIDTokenParsingFailed:
            return "⚠️ 애플 토큰 파싱에 실패했습니다."
        case .appleCanceled:
            return "⚠️ 사용자가 애플 로그인을 취소했습니다."
        case .unknown:
            return "⚠️ 알 수 없는 오류입니다."
        case .appleError:
            return "⚠️ 로그인에 실패하였습니다."
        case .firebaseError:
            return "⚠️ 서버 오류입니다."
        }
    }

    // MARK: - RepositoryError → UseCaseError 변환
    static func map(from error: RepositoryError) -> UseCaseError {
        switch error {
        case .appleInvalidCredential:
            return .appleInvalidCredential(error)
        case .appleNonceMissing:
            return .appleNonceMissing(error)
        case .appleIDTokenParsingFailed:
            return .appleIDTokenParsingFailed(error)
        case .appleCanceled:
            return .appleCanceled(error)
        case .appleError(let e):
            return .appleError(.appleCanceled(e))
        case .firebaseError(let e):
            return .firebaseError(.firebaseError(e))
        case .unknown(let e):
            return .unknown(.unknown(e))
        }
    }
}
