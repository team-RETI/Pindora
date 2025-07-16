//
//  DIContainer.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import Foundation

final class DIContainer {
    static let shared = DIContainer()
    private init() {}
    private var dependencies: [String: Any] = [:]
    
    // 메서드로 의존성을 등록
    func register<T>(_ type: T.Type, dependency: T) {
        let key = String(describing: type)
        dependencies[key] = dependency
    }
    
    // 메서드로 등록된 의존성을 가져오기
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let dependency = dependencies[key] as? T else {
            preconditionFailure("⚠️ \(key)는 register되지 않았습니다. resolve호출 전에 register 해주세요.")
        }
        return dependency
    }
}


/// DIContainer에서 자동으로 의존성을 주입받는 속성 래퍼입니다.
/// ex: @Dependency var service: SomeService
/// -> 내부적으로는 DIContainer.shared.resolve(SomeService.self)를 호출한 것과 동일합니다.
///
/// - T: 의존성 타입(ex: SomeService.self)
/// - resolve 시점에 등록되지 않은 경우 preconditionFailure로 앱이 중단될 수 있으므로,
///   사용 전에 DIContainer에 해당 타입을 register 해두어야 합니다.
/*
 사용 예시
 // ✅ 먼저 DIContainer에 의존성 등록
 DIContainer.shared.register(AuthService.self, dependency: RealAuthService())

 // ✅ 그리고 아래처럼 사용 가능
 final class LoginViewModel {
     // 이 속성은 DIContainer에서 자동으로 주입됩니다.
     @Dependency var authService: AuthService
 }
 */
@propertyWrapper
class Dependency<T> {
    
    // DIConatiner에서 resolve된 인스턴스를 자동으로 가져옵니다
    let wrappedValue: T
    
    // 생성 시점에 DIContainer로부터 의존성을 꺼내옵니다.
    init() {
        self.wrappedValue = DIContainer.shared.resolve(T.self)
    }
}

extension DIContainer {
    static func config() {
        // MARK: - Repository 생성
        let authRepository = AuthRepositoryImpl()
        
        // MARK: - Usecase 등록
        self.shared.register(
            AuthUseCase.self,
            dependency: AuthUseCaseImpl(authRepository: authRepository)
        )
    }
}
