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
    case oneTimeAsk
    
    case home
    case map
    case myPlace
    case addPlace
    case cardDetail
    case profile
    case editProfile
    case setting
    case accountSetting
}

// MARK: - ModuleFactory
/// ViewController 및 ViewModel을 생성하고, ViewModel을 캐싱하여 재사용하는 역할을 하는 팩토리 클래스입니다.
/// MVVM-C 아키텍처에서 Coordinator가 ViewController를 생성할 때 사용합니다.
final class ModuleFactory {
    static let shared = ModuleFactory()
    private init() {}
    private var viewModelCache: [ModuleKey: Any] = [:]
    
    // MARK: - ViewController 생성
    func makeLoginVC() -> LoginViewController {
        let viewModel: LoginViewModel = getOrCreateViewModel(for: .login) {
            let authUseCase = DIContainer.shared.resolve(AuthUseCaseProtocol.self)
            let userUsecase = DIContainer.shared.resolve(UserUseCaseProtocol.self)
            return LoginViewModel(authUseCase: authUseCase, userUseCase: userUsecase)
        }
        return LoginViewController(viewModel: viewModel)
    }
    
    func makeOneTimeAskVC() -> OneTimeAskViewController {
        let viewModel: LoginViewModel = getOrCreateViewModel(for: .oneTimeAsk) {
            let authUseCase = DIContainer.shared.resolve(AuthUseCaseProtocol.self)
            let userUsecase = DIContainer.shared.resolve(UserUseCaseProtocol.self)
            return LoginViewModel(authUseCase: authUseCase, userUseCase: userUsecase)
        }
        return OneTimeAskViewController(viewModel: viewModel)
    }
    
    func makeHomeVC() -> HomeViewController {
        let viewModel: HomeViewModel = getOrCreateViewModel(for: .home) {
            let locationUseCase = DIContainer.shared.resolve(LocationUseCaseProtocol.self)
            let searchUseCase = DIContainer.shared.resolve(SearchUseCaseProtocol.self)
            let placeUseCase = DIContainer.shared.resolve(PlaceUseCase.self)
            let userUseCase = DIContainer.shared.resolve(UserUseCaseProtocol.self)
            let imageUseCase = DIContainer.shared.resolve(ImageUsecaseProtocol.self)
            return HomeViewModel(locationUseCase: locationUseCase, searchUseCase: searchUseCase, imageUseCase: imageUseCase, placeUseCase: placeUseCase, userUseCase: userUseCase)
        }
        return HomeViewController(viewModel: viewModel)
    }
    
    func makeCardDetailVC(place: Place) -> CardDetailViewController {
        let viewModel: CardDetailViewModel = getOrCreateViewModel(for: .cardDetail) {
            let placeUseCase = DIContainer.shared.resolve(PlaceUseCase.self)
            let userUseCase = DIContainer.shared.resolve(UserUseCaseProtocol.self)
            let imageUseCase = DIContainer.shared.resolve(ImageUsecaseProtocol.self)
            return CardDetailViewModel(place: place, placeUseCase: placeUseCase, userUseCase: userUseCase, imageUseCase: imageUseCase)
        }
        return CardDetailViewController(viewModel: viewModel, place: place)
    }
    
    func makeMapVC() -> MapViewController {
        let viewModel: MapViewModel = getOrCreateViewModel(for: .map) {
            let locationUseCase: LocationUseCaseProtocol = DIContainer.shared.resolve(LocationUseCaseProtocol.self)
            let searchUseCase: SearchUseCaseProtocol = DIContainer.shared.resolve(SearchUseCaseProtocol.self)
            return MapViewModel(locationUseCase: locationUseCase, searchUseCase: searchUseCase)
        }
        return MapViewController(viewModel: viewModel)
    }
    
    func makeMyPlaceVC() -> MyPlaceViewController {
        let viewModel: MyPlaceViewModel = getOrCreateViewModel(for: .myPlace) {
            let searchUseCase = DIContainer.shared.resolve(SearchUseCaseProtocol.self)
            let placeUseCase = DIContainer.shared.resolve(PlaceUseCase.self)
            let userUseCase = DIContainer.shared.resolve(UserUseCaseProtocol.self)
            let imageUseCase = DIContainer.shared.resolve(ImageUsecaseProtocol.self)
            return MyPlaceViewModel(searchUseCase: searchUseCase, placeUseCase: placeUseCase, userUseCase: userUseCase, imageUseCase: imageUseCase)
        }
        return MyPlaceViewController(viewModel: viewModel)
    }
    
    func makeAddPlaceVC() -> AddPlaceViewController {
        let viewModel: AddPlaceViewModel = getOrCreateViewModel(for: .addPlace) {
            let searchUseCase = DIContainer.shared.resolve(SearchUseCaseProtocol.self)
            let placeUseCase = DIContainer.shared.resolve(PlaceUseCase.self)
            let imageUseCase = DIContainer.shared.resolve(ImageUsecaseProtocol.self)
            
            return AddPlaceViewModel(searchUseCase: searchUseCase, placeUseCase: placeUseCase, imageUseCase: imageUseCase)
        }
        return AddPlaceViewController(viewModel: viewModel)
    }
    
    func makeProfileVC() -> ProfileViewController {
        let viewModel: ProfileViewModel = getOrCreateViewModel(for: .profile) {
            let userUseCase = DIContainer.shared.resolve(UserUseCaseProtocol.self)
            let gptUseCase = DIContainer.shared.resolve(GPTUseCaseProtocol.self)
            return ProfileViewModel(userUseCase: userUseCase, gptUseCase: gptUseCase)
        }
        return ProfileViewController(viewModel: viewModel)
    }
    
    func makeProfileEditVC() -> ProfileEditViewController {
        let viewModel: ProfileEditViewModel = getOrCreateViewModel(for: .editProfile) {
            let imageUC = DIContainer.shared.resolve(ImageUsecaseProtocol.self)
            let userUC = DIContainer.shared.resolve(UserUseCaseProtocol.self)
            return ProfileEditViewModel(imageUseCase: imageUC, userUseCase: userUC)
        }
        return ProfileEditViewController(viewModel: viewModel)
    }
    
    func makeSettingVC() -> SettingListViewController {
        let viewModel: SettingListViewModel = getOrCreateViewModel(for: .setting) {
            SettingListViewModel()
        }
        return SettingListViewController(viewModel: viewModel)
    }
    
    func makeAccountSettingVC() -> AccountSettingViewController {
        let viewModel: AccountSettingViewModel = getOrCreateViewModel(for: .accountSetting) {
            AccountSettingViewModel()
        }
        return AccountSettingViewController(viewModel: viewModel)
    }
    
    func makeLoginViewModel() -> LoginViewModel {
        getOrCreateViewModel(for: .login) {
            let authUseCase = DIContainer.shared.resolve(AuthUseCaseProtocol.self)
            let userUseCase = DIContainer.shared.resolve(UserUseCaseProtocol.self)
            return LoginViewModel(authUseCase: authUseCase, userUseCase: userUseCase)
        }
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
