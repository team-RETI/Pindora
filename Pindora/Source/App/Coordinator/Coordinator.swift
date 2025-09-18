//
//  Coordinator.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import FirebaseAuth

protocol Coordinator: AnyObject {
    
    /// 현재 Coordinator를 소유한 상위 Coordinator입니다.
    /// 화면 흐름이 계층적으로 구성될 때, 상위 계층으로 연결하기 위해 사용합니다.
    var parentCoordinator: Coordinator? { get set }
    
    
    /// 현재 Coordinator가 관리하는 하위 Coordinator 목록입니다.
    /// 화면 흐름을 분리하고 메모리 관리를 용이하게 하기 위해 자식 Coordinator를 추적합니다.
    var childCoordinators: [Coordinator] { get set }
    
    
    /// Coordinator의 화면 흐름을 시작하는 메서드입니다.
    /// 일반적으로 ViewController를 생성하고 표시하는 역할을 수행합니다.
    func start()
}

extension Coordinator {
    
    /// 종료할 자식 Coordinator를 childCoordinators 배열에서 제거합니다.
    /// - Parameter child: 종료할 자식 Coordinator
    func childDidFinish(_ child: Coordinator?) {
        guard let child = child else { return }
        childCoordinators.removeAll { $0 === child }
    }
}

final class AppCoordinator: Coordinator {
    private enum Route {
        case login      // 로그인 코디네이터로 이동
        case mainTab    // 기존 사용자 -> 메인탭
    }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    var isLoggedIn: Bool = false
    
    init(
        navigationController: UINavigationController,
        isLoggedIn: Bool,
    ) {
        self.navigationController = navigationController
        self.isLoggedIn = isLoggedIn
    }
    
    func start() {
        // TODO: - ViewModel에서 판단해서 이 부분을 외부에서 호출하도록 설계하는 것이 핵심
        navigate(to: isLoggedIn ? .mainTab : .login)
    }
    
    func navigateToMainTab() {
        navigate(to: .mainTab)
    }
    
    private func navigate(to route: Route) {
        switch route {
        case .login:
            let login = LoginCoordinator(navigationController: navigationController)
            login.parentCoordinator = self
            childCoordinators.append(login)
            login.start()
            
        case .mainTab:
            let mainTab = MainTabCoordinator(navigationController: navigationController)
            mainTab.parentCoordinator = self
            childCoordinators.append(mainTab)
            mainTab.start()
        }
    }
}

final class LoginCoordinator: Coordinator {
    private enum Route {
        case login      // 로그인뷰
        case loginFlow  // 최초 사용자 -> 추천 카테고리 입력
        case mainTab    // 기존 사용자 -> 메인 탭
    }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    init(
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigate(to: .login)
    }
    
    func didTapLoginButton() {
        parentCoordinator?.childDidFinish(self)
        navigate(to: .loginFlow)
    }
    
    func navigateToMainTab() {
        navigate(to: .mainTab)
    }
    
    private func navigate(to route: Route) {
        switch route {
        case .login:
            let vc = ModuleFactory.shared.makeLoginVC()
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
            
        case .loginFlow:
            let loginFlow = LoginFlowCoordinator(navigationController: navigationController)
            loginFlow.parentCoordinator = self
            loginFlow.start()
            childCoordinators.append(loginFlow)
            
        case .mainTab:
            let mainTab = MainTabCoordinator(navigationController: navigationController)
            mainTab.parentCoordinator = self
            mainTab.start()
            childCoordinators.append(mainTab)

        }
    }
}

final class LoginFlowCoordinator: Coordinator {
    private enum Route {
        case oneTimeAsk
    }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    init(
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigate(to: .oneTimeAsk)
    }
    
    func navigateToMainTab() {
        parentCoordinator?.childDidFinish(self)
        if let appCoordinator = parentCoordinator as? LoginCoordinator {
            appCoordinator.navigateToMainTab()
        }
    }
    
    private func navigate(to route: Route) {
        switch route {
        case .oneTimeAsk:
            let vc: OneTimeAskViewController = ModuleFactory.shared.makeOneTimeAskVC()
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
            //navigationController.setViewControllers([vc], animated: true)
        }
    }
}

final class MainTabCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    private let tabbarController = UITabBarController()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func navigateToLogin() {
        parentCoordinator?.childDidFinish(self)
        if let appCoordinator = parentCoordinator as? LoginCoordinator {
            appCoordinator.start()
        }
        if let appCoordinator = parentCoordinator as? AppCoordinator {
            appCoordinator.isLoggedIn = false
            appCoordinator.start()
        }
    }
    
    func start() {
        let homeNav = UINavigationController()
        let mapNav = UINavigationController()
        let myPlaceNav = UINavigationController()
        let profileNav = UINavigationController()
        
        // tabBarItem 설정
        homeNav.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
        mapNav.tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map"), tag: 1)
        myPlaceNav.tabBarItem = UITabBarItem(title: "내 장소", image: UIImage(systemName: "bookmark"), tag: 2)
        profileNav.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), tag: 3)
        
        let home = HomeCoordinator(navigationController: homeNav)
        let map = MapCoordinator(navigationController: mapNav)
        let myPlace = MyPlaceCoordinator(navigationController: myPlaceNav)
        let profile = ProfileCoordinator(navigationController: profileNav)
        
        let coordinators: [Coordinator] = [home, map, myPlace, profile]
        coordinators.forEach {
            $0.parentCoordinator = self
            $0.start()
            self.childCoordinators.append($0) // ✅ 여기
        }
        tabbarController.setViewControllers([homeNav, mapNav, myPlaceNav, profileNav], animated: false)
        navigationController.pushViewController(tabbarController, animated: true)
        navigationController.isNavigationBarHidden = true
        tabbarController.tabBar.tintColor = .gray
        tabbarController.tabBar.unselectedItemTintColor = .lightGray
    }
}

protocol CardDetailCoordinating: AnyObject {
    /// 이동
    func didTapCell(place: Place)
    /// 이동
    func didTapPlaceMarker(place: Place, onDismiss: @escaping () -> Void)
    //    func navigateToPlaceDetail()
    // 여기에 필요한 이동 메서드 추가
}

final class HomeCoordinator: NSObject, Coordinator, UIAdaptivePresentationControllerDelegate, CardDetailCoordinating {
    private var onPlaceSheetDismiss: (() -> Void)?
    private var place: Place?
    
    func didTapPlaceMarker(place: Place, onDismiss: @escaping () -> Void) {  }
    func didTapCell(place: Place) {
        self.place = place
        navigate(to: .cardDetail)
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        let fireDismiss: () -> Void = { [weak self] in
            self?.onPlaceSheetDismiss?()
            self?.onPlaceSheetDismiss = nil
            self?.place = nil
            ModuleFactory.shared.removeViewModel(for: .cardDetail)
        }

        if let bgView = navigationController.view.viewWithTag(999) {
            UIView.animate(withDuration: 0.25, animations: {
                bgView.alpha = 0
            }, completion: { _ in
                bgView.removeFromSuperview()
                fireDismiss() // ✅ 페이드 완전히 끝난 뒤 콜백
            })
        } else {
            fireDismiss()     // ✅ 배경 없으면 바로 콜백
        }
    }
    
    private enum Route {
        case home
        case cardDetail
    }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigate(to: .home)
    }
    
    private func navigate(to route: Route) {
        switch route {
        case .home:
            let vc = ModuleFactory.shared.makeHomeVC()
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: false)
            navigationController.isNavigationBarHidden = true // ✅ 요거 추가
            
            
        case .cardDetail:
            guard let place else { return }
            let vc = ModuleFactory.shared.makeCardDetailVC(place: place)
            vc.coordinator = self as CardDetailCoordinating
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            nav.view.backgroundColor = .clear
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            vc.presentationController?.delegate = self
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [
                    .custom(resolver: { context in
                        return context.maximumDetentValue * 0.98
                    })
                ]
                sheet.prefersGrabberVisible = false
            }
            
            // ✅ 배경 뷰 추가
            let bgView = UIView(frame: navigationController.view.bounds)
            bgView.backgroundColor = .black
            bgView.alpha = 0
            bgView.tag = 999  // 나중에 제거용

//            let backgroundImageView = UIImageView(frame: bgView.bounds)
//            backgroundImageView.image = UIImage(named: "sample_main")
//            backgroundImageView.contentMode = .scaleAspectFill
//            backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            bgView.addSubview(backgroundImageView)
            navigationController.view.addSubview(bgView)
            
            UIView.animate(withDuration: 0.5) {
                bgView.alpha = 1
            }
            
            // ✅ delegate 설정
            nav.presentationController?.delegate = self
            nav.isNavigationBarHidden = true
            navigationController.present(nav, animated: true)
        }
    }
}

final class MapCoordinator: NSObject, Coordinator, CardDetailCoordinating, UIAdaptivePresentationControllerDelegate {
    private var onPlaceSheetDismiss: (() -> Void)?
    private var place: Place?
    func didTapCell(place: Place) {
        self.place = place
        navigate(to: .home)
    }
    
    func didTapPlaceMarker(place: Place, onDismiss: @escaping () -> Void) {
        self.onPlaceSheetDismiss = onDismiss
        self.place = place
        navigate(to: .cardDetail)
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        let fireDismiss: () -> Void = { [weak self] in
            self?.onPlaceSheetDismiss?()
            self?.onPlaceSheetDismiss = nil
            self?.place = nil
            ModuleFactory.shared.removeViewModel(for: .cardDetail)
        }

        if let bgView = navigationController.view.viewWithTag(999) {
            UIView.animate(withDuration: 0.25, animations: {
                bgView.alpha = 0
            }, completion: { _ in
                bgView.removeFromSuperview()
                fireDismiss() // ✅ 페이드 완전히 끝난 뒤 콜백
            })
        } else {
            fireDismiss()     // ✅ 배경 없으면 바로 콜백
        }
    }
    
    private enum Route {
        case home
        case cardDetail
    }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigate(to: .home)
    }
    
    private func navigate(to route: Route) {
        switch route {
        case .home:
            let vc = ModuleFactory.shared.makeMapVC()
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: false)
            navigationController.isNavigationBarHidden = true
            
        case .cardDetail:
            guard let place else { return }
            let vc = ModuleFactory.shared.makeCardDetailVC(place: place)
            vc.coordinator = self as CardDetailCoordinating
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            nav.view.backgroundColor = .clear
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            vc.presentationController?.delegate = self
            
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
            
            nav.presentationController?.delegate = self
            nav.isNavigationBarHidden = true
            navigationController.present(nav, animated: true)
        }
    }
}

final class MyPlaceCoordinator: NSObject, Coordinator, CardDetailCoordinating, UIAdaptivePresentationControllerDelegate {
    private var onPlaceSheetDismiss: (() -> Void)?
    var onPlaceSaved: (() -> Void)?
    private var place: Place?
    
    func didTapPlaceMarker(place: Place, onDismiss: @escaping () -> Void) { }
    func didTapAddPlace() {
        navigate(to: .addPlace)
    }
    func didTapCell(place: Place) {
        self.place = place
        navigate(to: .cardDetail)
    }
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        let fireDismiss: () -> Void = { [weak self] in
            self?.onPlaceSheetDismiss?()
            self?.onPlaceSheetDismiss = nil
            self?.place = nil
            ModuleFactory.shared.removeViewModel(for: .cardDetail)
        }

        if let bgView = navigationController.view.viewWithTag(999) {
            UIView.animate(withDuration: 0.25, animations: {
                bgView.alpha = 0
            }, completion: { _ in
                bgView.removeFromSuperview()
                fireDismiss() // ✅ 페이드 완전히 끝난 뒤 콜백
            })
        } else {
            fireDismiss()     // ✅ 배경 없으면 바로 콜백
        }
    }
    
    private enum Route {
        case home
        case addPlace
        case cardDetail
    }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    func start() {
        navigate(to: .home)
    }
    
    private func navigate(to route: Route) {
        switch route {
        case .home:
            let vc = ModuleFactory.shared.makeMyPlaceVC()
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: false)
            navigationController.isNavigationBarHidden = true // ✅ 요거 추가
            
        case .addPlace:
            let vc = ModuleFactory.shared.makeAddPlaceVC()
            
            vc.onSaved = { [weak self] in
                 self?.onPlaceSaved?() 
             }
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .popover//.pageSheet
            
            // ✅ iOS 15+ sheet 스타일 적용 (크기 조절 가능하도록)
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [
                    .custom(resolver: { context in
                        return context.maximumDetentValue * 0.99
                    })]
                sheet.prefersGrabberVisible = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                
            }
            nav.isNavigationBarHidden = true // ✅ 요거 추가
            navigationController.present(nav, animated: true)
            
        case .cardDetail:
            guard let place else { return }
            let vc = ModuleFactory.shared.makeCardDetailVC(place: place)
            vc.coordinator = self as CardDetailCoordinating
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            nav.view.backgroundColor = .clear
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            vc.presentationController?.delegate = self
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [
                    .custom(resolver: { context in
                        return context.maximumDetentValue * 0.98
                    })
                ]
                sheet.prefersGrabberVisible = false
            }
            
            // ✅ 배경 뷰 추가
            let bgView = UIView(frame: navigationController.view.bounds)
            bgView.backgroundColor = .black
            bgView.alpha = 0
            bgView.tag = 999  // 나중에 제거용
            
//            let backgroundImageView = UIImageView(frame: bgView.bounds)
//            backgroundImageView.image = UIImage(named: "sample_main")
//            backgroundImageView.contentMode = .scaleAspectFill
//            backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//            bgView.addSubview(backgroundImageView)
            navigationController.view.addSubview(bgView)
            
            UIView.animate(withDuration: 0.5) {
                bgView.alpha = 1
            }
            
            // ✅ delegate 설정
            nav.presentationController?.delegate = self
            nav.isNavigationBarHidden = true
            navigationController.present(nav, animated: true)
        }
    }
}

final class ProfileCoordinator: Coordinator {
    func didTapLogout() {
        navigateToLogin()
    }
    
    func didTapDeleteAccount() {
        navigationController.popViewController(animated: true)
    }
    
    func backButtonTapped() {
        navigationController.popViewController(animated: true)
    }
    
    func didTapRegisterButton() {
        navigationController.popViewController(animated: true)
    }
    
    func didTapAccountSetting() {
        navigate(to: .accountSetting)
    }
    
    func didTapTermsOfService() {
        navigationController.popViewController(animated: true)
    }
    
    func didTapPrivacyPolicy() {
        navigationController.popViewController(animated: true)
    }
    
    func didTapEditProfile() {
        navigate(to: .editProfile)
    }
    func didTapSetting() {
        navigate(to: .setting)
    }
    
    private enum Route {
        case home
        case editProfile
        case setting
        case accountSetting
    }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigate(to: .home)
    }
    
    func navigateToLogin() {
        finishFlow()
        if let appCoordinator = parentCoordinator as? MainTabCoordinator {
            appCoordinator.navigateToLogin()
        }
    }
    
    func finishFlow() {
        parentCoordinator?.childDidFinish(self)
        ModuleFactory.shared.clearAllViewModels()
    }
    
    private func navigate(to route: Route) {
        switch route {
        case .home:
            let vc = ModuleFactory.shared.makeProfileVC()
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
            navigationController.isNavigationBarHidden = true  //✅ 요거 추가
            
        case .editProfile:
            let vc = ModuleFactory.shared.makeProfileEditVC()
            vc.coordinator = self
            vc.hidesBottomBarWhenPushed = true
            navigationController.pushViewController(vc, animated: true)
            navigationController.isNavigationBarHidden = true
            
        case .setting:
            let vc = ModuleFactory.shared.makeSettingVC()
            vc.coordinator = self
            vc.hidesBottomBarWhenPushed = true
            navigationController.pushViewController(vc, animated: true)
            navigationController.isNavigationBarHidden = true
            
        case .accountSetting:
            let vc = ModuleFactory.shared.makeAccountSettingVC()
            vc.coordinator = self
            vc.hidesBottomBarWhenPushed = true
            navigationController.pushViewController(vc, animated: true)
            navigationController.isNavigationBarHidden = true
        
        }
    }
}
