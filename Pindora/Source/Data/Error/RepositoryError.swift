//
//  RepositoryError.swift
//  Pindora
//
//  Created by 김동현 on 8/18/25.
//

import Foundation

enum RepositoryError: Error, NestedError {
    case unknown(Error)
    
    static func map(from infra: InfraError) -> RepositoryError {
        switch infra {
        default:    return .unknown(infra)
        }
    }
}

extension RepositoryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown(let underlying):
            return "\(underlying.localizedDescription)"
        }
    }
    
    var underlying: Error? {
        switch self {
        case .unknown(let e): return e
        }
    }
}
