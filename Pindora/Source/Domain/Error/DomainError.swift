//
//  ServiceError.swift
//  Pindora
//
//  Created by 김동현 on 8/17/25.
//

import Foundation

enum DomainError: LocalizedError {
    case invalidState
    case userNotFound
    case error(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidState: return "⚠️ 현재 사용자 UID가 없습니다."
        case .userNotFound:      return "⚠️ 사용자를 찾을 수 없습니다."
        case .error(let e):      return e.localizedDescription
        }
    }
}
 
