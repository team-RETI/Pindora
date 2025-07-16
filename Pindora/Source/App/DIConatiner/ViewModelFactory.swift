//
//  ViewModelFactory.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//
// https://medium.com/@jislam150/viewmodelprovider-using-abstractfactory-pattern-in-swift-4f26d92368c0

import Foundation

// MARK: - Base ViewModel Protocol
protocol ViewModel {
    func viewModelDidRemoved()
}

extension ViewModel {
    func viewModelDidRemoved() {}  // // Optional override
}

// MARK: - Abstract Factory
final class ViewModelFactory {
    static let shared = ViewModelFactory()

    private init() {}
    
    // ViewModel 생성 책임(override 필수)
    func createViewModel<V: ViewModel>(type: V.Type) -> V? {
        
        // LoginViewModel
        if type == LoginViewModel.self {
            let usecase = DIContainer.shared.resolve(AuthUseCase.self)
            return LoginViewModel(authUseCase: usecase) as? V
        }

        // HomeViewModel
        else if type == HomeViewModel.self {
            return HomeViewModel() as? V
        }

        // MapViewModel
        else if type == MapViewModel.self {
            return MapViewModel() as? V
        }

        // MyPlaceViewModel
        else if type == MyPlaceViewModel.self {
            return MyPlaceViewModel() as? V
        }

        // ProfileViewModel
        else if type == ProfileViewModel.self {
            return ProfileViewModel() as? V
        }

        // default
        return nil
    }


}

// MARK: - ViewModelProvider
final class ViewModelProvider {
    static let shared = ViewModelProvider()
    private var cache: [ObjectIdentifier: ViewModel] = [:]
    
    // viewModel 제공
    func resolve<T: ViewModel>(
        factory: ViewModelFactory,
        type: T.Type
    ) -> T? {
        let key = ObjectIdentifier(type)
        
        if let cached = cache[key] as? T {
            print("✅ 뷰모델 재사용: \(type)")
            return cached
        }
        
        guard let newVM = factory.createViewModel(type: type) else {
            print("❌ 뷰모델 생성 실패: \(type)")
            return nil
        }
        
        cache[key] = newVM
        return newVM
    }
    
    // 캐시 제거
    func clear<T: ViewModel>(type: T.Type) {
        let key = ObjectIdentifier(type)
        cache.removeValue(forKey: key)
    }
    
    // 전체 초기화
    func reset() {
        cache.removeAll()
    }
}
