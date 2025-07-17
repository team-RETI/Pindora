// The Swift Programming Language
// https://docs.swift.org/swift-book

// The Swift Programming Language
// https://docs.swift.org/swift-book

// import SwiftSyntax
// import SwiftParser
// import Foundation

// final class UndocumentedProtocolChecker: SyntaxVisitor {
//     override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
//         print("📌 프로토콜 발견: \(node.name.text)")
//         for member in node.memberBlock.members {
//             if let funcDecl = member.decl.as(FunctionDeclSyntax.self) {
//                 checkDoc(for: funcDecl.name.text, trivia: funcDecl.leadingTrivia)
//             }
//             if let varDecl = member.decl.as(VariableDeclSyntax.self) {
//                 let name = varDecl.bindings.first?.pattern.description ?? "var"
//                 checkDoc(for: name, trivia: varDecl.leadingTrivia)
//             }
//         }
//         return .skipChildren
//     }

//     private func checkDoc(for name: String, trivia: Trivia) {
//         let documented = trivia.contains {
//             if case let .docLineComment(comment) = $0 {
//                 return comment.trimmingCharacters(in: .whitespaces).hasPrefix("///")
//             }
//             return false
//         }

//         if !documented {
//             print("⚠️ '\(name)'은(는) 문서화 주석이 없습니다. → 프로토콜 멤버에 `///` 주석을 추가해주세요.")
//         }
//     }
// }

// func runChecker(on folderPath: String) {
//     let fileManager = FileManager.default
//     guard let subpaths = fileManager.subpaths(atPath: folderPath) else {
//         print("❌ 디렉토리 탐색 실패: \(folderPath)")
//         return
//     }

//     let swiftFiles = subpaths.filter { $0.hasSuffix(".swift") }

//     for file in swiftFiles {
//         let fullPath = URL(fileURLWithPath: folderPath).appendingPathComponent(file).path
//         do {
//             let source = try String(contentsOfFile: fullPath)
//             let syntaxTree = Parser.parse(source: source)
//             let checker = UndocumentedProtocolChecker(viewMode: .sourceAccurate)
//             print("🚀 파일 분석 시작: \(file)")
//             checker.walk(syntaxTree)
//         } catch {
//             print("❌ 분석 실패: \(file) — \(error)")
//         }
//     }
// }

// // MARK: - Entry

// let args = CommandLine.arguments
// guard args.count > 1 else {
//     print("❗️ 분석할 폴더 경로를 인자로 전달해주세요.")
//     exit(1)
// }

// let folderPath = args[1]
// runChecker(on: folderPath)

// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftSyntax
import SwiftParser
import Foundation

final class UndocumentedProtocolChecker: SyntaxVisitor {
    private let fileName: String
    private let locationConverter: SourceLocationConverter

    init(fileName: String, tree: SourceFileSyntax) {
        self.fileName = fileName
        self.locationConverter = SourceLocationConverter(fileName: fileName, tree: tree)
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        for member in node.memberBlock.members {
            if let funcDecl = member.decl.as(FunctionDeclSyntax.self) {
                checkDoc(
                    for: funcDecl.name.text,
                    trivia: funcDecl.leadingTrivia,
                    position: funcDecl.positionAfterSkippingLeadingTrivia // ✅ 수정
                )
            }
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                let name = varDecl.bindings.first?.pattern.description.trimmingCharacters(in: .whitespacesAndNewlines) ?? "var"
                checkDoc(
                    for: name,
                    trivia: varDecl.leadingTrivia,
                    position: varDecl.positionAfterSkippingLeadingTrivia // ✅ 수정
                )
            }
        }
        return .skipChildren
    }


    private func checkDoc(for name: String, trivia: Trivia, position: AbsolutePosition) {
        let documented = trivia.contains {
            if case let .docLineComment(comment) = $0 {
                return comment.trimmingCharacters(in: .whitespaces).hasPrefix("///")
            }
            return false
        }

        if !documented {
            let location = locationConverter.location(for: position)
            print("\(fileName):\(location.line):\(location.column): warning: '\(name)'는 문서화 주석이 없습니다. ✅ 코드 컨벤션에 따라 프로토콜의 함수와 변수에는 반드시 /// 주석을 작성해야 합니다. (문서화 주석 단축키: ⌘ + ⌥ + /)")
        }
    }
}

func runChecker(on folderPath: String) {
    let fileManager = FileManager.default
    guard let subpaths = fileManager.subpaths(atPath: folderPath) else {
        print("❌ 디렉토리 탐색 실패: \(folderPath)")
        return
    }

    let swiftFiles = subpaths.filter { $0.hasSuffix(".swift") }

    for file in swiftFiles {
        let fullPath = URL(fileURLWithPath: folderPath).appendingPathComponent(file).path
        do {
            let source = try String(contentsOfFile: fullPath)
            let syntaxTree = Parser.parse(source: source)
            let checker = UndocumentedProtocolChecker(fileName: fullPath, tree: syntaxTree)
            checker.walk(syntaxTree)
        } catch {
            print("❌ 분석 실패: \(file) — \(error)")
        }
    }
}

// MARK: - Entry Point

let args = CommandLine.arguments
guard args.count > 1 else {
    print("❗️ 분석할 폴더 경로를 인자로 전달해주세요.")
    exit(1)
}

let folderPath = args[1]
runChecker(on: folderPath)
