//
//  Error+.swift
//  Pindora
//
//  Created by 김동현 on 8/20/25.
//

import Foundation

// MARK: - Error+Trace.swift
extension Error {
    var caseName: String {
        let mirror = Mirror(reflecting: self)
        let typeName = String(describing: type(of: self))
        if let child = mirror.children.first {
            return "\(typeName).\(child.label ?? "unknown")"
        } else {
            return "\(typeName).\(self)"
        }
    }

    func printFullTrace(level: Int = 0) {
        let indent = String(repeating: "   ", count: level)
        let message = (self as? LocalizedError)?.errorDescription ?? self.localizedDescription
        print("\(indent)↳ [\(self.caseName)] \(message)")

        if let nested = self as? NestedError, let inner = nested.underlying {
            inner.printFullTrace(level: level + 1)
        }
    }
}



/*
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
*/
