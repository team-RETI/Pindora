//
//  ServiceError.swift
//  Pindora
//
//  Created by 김동현 on 8/17/25.
//

import Foundation

/// 에러 체이닝(원인 추적)을 위한 프로토콜입니다
///
/// 하나의 에러가 다른 에러를 감싸고 있을 경우(`wrap`),
/// 최종적으로 어떤 에러가 발생했는지 계층적으로 추적할 수 있게 도와줍니다.
///
/// 예를 들어, UseCaseError가 RepositoryError를 감싸고,
/// RepositoryError가 InfraError를 감쌌다면,
/// `underlying`을 따라가며 전체 에러 흐름을 추적할 수 있습니다.
protocol NestedError: Error {
    var underlying: Error? { get }
}

enum UseCaseError: Error, NestedError {
    case invalidState
    case userNotFound
    case unknown(Error)
    
    static func map(from repo: RepositoryError) -> UseCaseError {
        switch repo {
        case .unknown(let error):   return .unknown(error)
        }
    }
}
 
extension UseCaseError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidState:         return "⚠️ 현재 사용자 UID가 없습니다."
        case .userNotFound:         return "⚠️ 사용자를 찾을 수 없습니다."
        case .unknown(let e):       return e.localizedDescription // 예상하지 못한 에러
        }
    }
    
    /// 로깅 체인을 위한 underlying
    var underlying: Error? {
        switch self {
        case .invalidState, .userNotFound:  return self
        case .unknown(let error):           return error
        }
    }
}

func caseName(of error: Error) -> String {
    let mirror = Mirror(reflecting: error)
    
    // Optional: 타입 이름
    let typeName = String(describing: type(of: error))
    
    if let child = mirror.children.first {
        return "\(typeName).\(child.label ?? "unknown")"
    } else {
        // associated value 없는 단순 케이스
        return "\(typeName).\(error)"
    }
}

func printFullErrorTrace(error: Error, level: Int = 0) {
    let indent = String(repeating: "   ", count: level)
    let caseTitle = caseName(of: error)
    let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription

    print("\(indent)↳ [\(caseTitle)] \(message)")

    if let nested = error as? NestedError, let inner = nested.underlying {
        printFullErrorTrace(error: inner, level: level + 1)
    }
}




/*
func printFullErrorTrace(error: Error, level: Int = 0) {
    let indent = String(repeating: "   ", count: level)
    
    let typeName = type(of: error)
    
    print("\(indent)↳ [\(typeName)] \(error.localizedDescription)")
    
    switch error {
    case let e as UseCaseError:
        if let inner = e.underlying { printFullErrorTrace(error: inner, level: level + 1) }
    case let e as RepositoryError:
        if let inner = e.underlying { printFullErrorTrace(error:inner, level: level + 1) }
    case let e as InfraError:
        _ = e
    default:
        break
    }
}
*/



/*
func printFullErrorTrace(error: Error, level: Int = 0) {
    let indent = String(repeating: "   ", count: level)
    
    print("\(indent)↳ [\(type(of: error))] \(error.localizedDescription)")
    switch error {
    case let e as UseCaseError:
        if let inner = e.underlying { printFullErrorTrace(error: inner, level: level + 1) }
    case let e as RepositoryError:
        if let inner = e.underlying { printFullErrorTrace(error: inner, level: level + 1) }
    case let e as InfraError:
        // InfraError 안에 또 다른 원인이 있을 수 있으나 여기선 끝
        _ = e
    default:
        break
    }
}
*/
