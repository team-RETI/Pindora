//
//  ModuleFactory.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

// MARK: - ModuleKey
/// 생성하거나 캐싱할 ViewModel의 종류를 구분하기 위한 키입니다.
/// 각 화면과 1:1로 매핑됩니다.
enum ModuleKey: String {
    case login
    case home
    case map
    case myPlace
    case profile
}

// MARK: - ModuleFactory
/// ViewController 및 ViewModel을 생성하고, ViewModel을 캐싱하여 재사용하는 역할을 하는 팩토리 클래스입니다.
/// MVVM-C 아키텍처에서 Coordinator가 ViewController를 생성할 때 사용합니다.
final class ModuleFactory {
    static let shared = ModuleFactory()
    private init() {}
    private var viewModelCache: [ModuleKey: Any] = [:]
    
    // MARK: - ViewController 생성
    func makeLoginVC() -> UIViewController {
        let viewModel: LoginViewModel = getOrCreateViewModel(for: .login) {
            let useCase = DIContainer.shared.resolve(AuthUseCase.self)
            return LoginViewModel(authUseCase: useCase)
        }
        return LoginViewController(viewModel: viewModel)
    }
    
    func makeOneTimeAskVC() -> UIViewController {
        let viewModel: LoginViewModel = getOrCreateViewModel(for: .login) {
            let useCase = DIContainer.shared.resolve(AuthUseCase.self)
            return LoginViewModel(authUseCase: useCase)
        }
        return OneTimeAskViewController(viewModel: viewModel)
    }
    
    func makeHomeVC() -> UIViewController {
        let viewModel: HomeViewModel = getOrCreateViewModel(for: .home) {
            HomeViewModel()
        }
        return HomeViewController(viewModel: viewModel)
    }
    
    func makeMapVC() -> UIViewController {
        let viewModel: MapViewModel = getOrCreateViewModel(for: .map) {
            MapViewModel()
        }
        return MapViewController(viewModel: viewModel)
    }
    
    func makeMyPlaceVC() -> UIViewController {
        let viewModel: MyPlaceViewModel = getOrCreateViewModel(for: .myPlace) {
            MyPlaceViewModel()
        }
        return MyPlaceViewController(viewModel: viewModel)
    }
    
    func makeProfileVC() -> UIViewController {
        let viewModel: ProfileViewModel = getOrCreateViewModel(for: .profile) {
            ProfileViewModel()
        }
        return ProfileViewController(viewModel: viewModel)
    }
    
    /// 이미 생성된 ViewModel이 있다면 반환하고,
    /// 없으면 factory 클로저를 실행해 새로 만들고 캐시에 저장한 후 반환합니다.
    ///
    /// - Parameters:
    ///   - key: ViewModel 구분 키 (ModuleKey)
    ///   - factory: ViewModel 생성 로직
    /// - Returns: 캐싱되었거나 새로 생성된 ViewModel
    private func getOrCreateViewModel<T>(for key: ModuleKey, factory: () -> T) -> T {
        if let cached = viewModelCache[key] as? T {
            return cached
        } else {
            let newVM = factory()
            viewModelCache[key] = newVM
            return newVM
        }
    }
    
    /// 특정 ViewModel만 캐시에서 제거합니다.
    /// 주로 로그아웃, 상태 초기화 시 사용됩니다.
    func removeViewModel(for key: ModuleKey) {
        viewModelCache[key] = nil
    }
    
    /// 모든 ViewModel 캐시를 초기화합니다.
    /// 주로 앱 리셋, 사용자 전환 시 사용됩니다.
    func clearAllViewModels() {
        viewModelCache.removeAll()
    }
}
