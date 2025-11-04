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
    
    // 자식 보관
    private(set) var homeCoordinator: HomeCoordinator?
    private(set) var mapCoordinator: MapCoordinator?
    private(set) var myPlaceCoordinator: MyPlaceCoordinator?
    private(set) var profileCoordinator: ProfileCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func openMap(place: Place) {
        // 맵뷰로 전환
        tabbarController.selectedIndex = 1
        mapCoordinator?.focusOnPlace(place)
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
        
        self.homeCoordinator = home
        self.mapCoordinator = map
        self.myPlaceCoordinator = myPlace
        self.profileCoordinator = profile
        
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
    /// 이동
    func didTapMapViewButton(place: Place)
    /// 이동
    func didTapReviewButton()
}

final class HomeCoordinator: NSObject, Coordinator, UIAdaptivePresentationControllerDelegate, CardDetailCoordinating {
    var onPlaceSheetDismiss: (() -> Void)?
    private var place: Place?
    func didTapPlaceMarker(place: Place, onDismiss: @escaping () -> Void) {  }
    func didTapReviewButton() {  }

    func didTapMapViewButton(place: Place) {
        dissmissPlaceSheet()
        (parentCoordinator as? MainTabCoordinator)?.openMap(place: place)
    }
    
    func didTapCell(place: Place) {
        self.place = place
        navigate(to: .cardDetail)
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dissmissPlaceSheet()
    }
    
    func dissmissPlaceSheet() {
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
    
    private func normalizeNaverNewsImageURL(_ urlString: String?) -> URL? {
        guard var s = urlString, !s.isEmpty else { return nil }
        
        // http → https
        if s.hasPrefix("http://") {
            s = "https://" + s.dropFirst(7)
        }
        
        guard var comp = URLComponents(string: s) else { return nil }
        
        // imgnews.naver.net → imgnews.pstatic.net (호스트 불일치 해결)
        if let host = comp.host, host == "imgnews.naver.net" {
            comp.host = "imgnews.pstatic.net"
        }
        
        return comp.url
    }
    
    func loadImage(into imageView: UIImageView, urlString: String?) {
        imageView.image = UIImage(named: "placeholder")
        
        guard let url = normalizeNaverNewsImageURL(urlString) else { return }
        
        var req = URLRequest(url: url,
                             cachePolicy: .returnCacheDataElseLoad,
                             timeoutInterval: 15)
        
        // 가끔 UA 필요할 때가 있어 기본 UA 부여
        req.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile",
                     forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err {
                print("❌ Image load failed:", err.localizedDescription)
                return
            }
            if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                print("❌ HTTP \(http.statusCode) for \(url)")
                return
            }
            guard let data = data, let img = UIImage(data: data) else {
                print("❌ Decode failed")
                return
            }
            DispatchQueue.main.async {
                imageView.image = img
            }
        }.resume()
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
            vc.view.backgroundColor = .clear
            vc.presentationController?.delegate = self
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            nav.view.backgroundColor = .clear
            
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [
                    .custom(resolver: { context in
                        return context.maximumDetentValue * 0.98
                    })
                ]
                sheet.prefersGrabberVisible = false
            }
            
            // 블러
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            blur.frame = nav.view.bounds
            blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            nav.view.insertSubview(blur, at: 0)
            
            // 배경 뷰 추가
            let bgView = UIView(frame: navigationController.view.bounds)
            bgView.backgroundColor = .black
            bgView.alpha = 0
            bgView.tag = 999  // 나중에 제거용
            
            let backgroundImageView = UIImageView(frame: bgView.bounds)
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            bgView.addSubview(backgroundImageView)
            
            loadImage(
                into: backgroundImageView,
                urlString: place.imageURL,
            )
            
            navigationController.view.addSubview(bgView)
            
            UIView.animate(withDuration: 0.5) {
                bgView.alpha = 1
            }
            
            // delegate 설정
            nav.presentationController?.delegate = self
            nav.isNavigationBarHidden = true
            navigationController.present(nav, animated: true)
        }
    }
}

final class MapCoordinator: NSObject, Coordinator, CardDetailCoordinating, UIAdaptivePresentationControllerDelegate {
    var onPlaceSheetDismiss: (() -> Void)?
    private var place: Place?
    func didTapCell(place: Place) {  }
    func didTapMapViewButton(place: Place) {   }
    func didTapReviewButton() {   }
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
    
    func focusOnPlace(_ place: Place) {
        // 루트 MapVC를 찾아서 지시
        if let mapVC = navigationController.viewControllers.first(where: { $0 is MapViewController }) as? MapViewController {
            mapVC.renderPlaceOnMap(place)
        } else {
            // 혹시 루트가 없으면 홈부터 세팅
            let vc = ModuleFactory.shared.makeMapVC()
            vc.coordinator = self
            navigationController.setViewControllers([vc], animated: false)
            vc.renderPlaceOnMap(place)
        }
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
    var onPlaceSheetDismiss: (() -> Void)?
    private var place: Place?
    func didTapReviewButton() {   }
    func didTapPlaceMarker(place: Place, onDismiss: @escaping () -> Void) { }    
    func didTapMapViewButton(place: Place) {
        dissmissPlaceSheet()
        (parentCoordinator as? MainTabCoordinator)?.openMap(place: place)
    }
    
    func didTapAddPlace() {
        navigate(to: .addPlace)
    }
    func didTapCell(place: Place) {
        self.place = place
        navigate(to: .cardDetail)
    }
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dissmissPlaceSheet()
    }
    
    func dissmissPlaceSheet() {
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
    
    private func normalizeNaverNewsImageURL(_ urlString: String?) -> URL? {
        guard var s = urlString, !s.isEmpty else { return nil }
        
        // http → https
        if s.hasPrefix("http://") {
            s = "https://" + s.dropFirst(7)
        }
        
        guard var comp = URLComponents(string: s) else { return nil }
        
        // imgnews.naver.net → imgnews.pstatic.net (호스트 불일치 해결)
        if let host = comp.host, host == "imgnews.naver.net" {
            comp.host = "imgnews.pstatic.net"
        }
        
        return comp.url
    }
    
    func loadImage(into imageView: UIImageView, urlString: String?) {
        imageView.image = UIImage(named: "placeholder")
        
        guard let url = normalizeNaverNewsImageURL(urlString) else { return }
        
        var req = URLRequest(url: url,
                             cachePolicy: .returnCacheDataElseLoad,
                             timeoutInterval: 15)
        
        // 가끔 UA 필요할 때가 있어 기본 UA 부여
        req.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile",
                     forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err {
                print("❌ Image load failed:", err.localizedDescription)
                return
            }
            if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                print("❌ HTTP \(http.statusCode) for \(url)")
                return
            }
            guard let data = data, let img = UIImage(data: data) else {
                print("❌ Decode failed")
                return
            }
            DispatchQueue.main.async {
                imageView.image = img
            }
        }.resume()
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
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .popover//.pageSheet
            
            // iOS 15+ sheet 스타일 적용 (크기 조절 가능하도록)
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
            vc.view.backgroundColor = .clear
            vc.presentationController?.delegate = self
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            nav.view.backgroundColor = .clear
            
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [
                    .custom(resolver: { context in
                        return context.maximumDetentValue * 0.98
                    })
                ]
                sheet.prefersGrabberVisible = false
            }
            
            // 블러
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            blur.frame = nav.view.bounds
            blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            nav.view.insertSubview(blur, at: 0)
            
            // 배경 뷰 추가
            let bgView = UIView(frame: navigationController.view.bounds)
            bgView.backgroundColor = .black
            bgView.alpha = 0
            bgView.tag = 999  // 나중에 제거용
            
            let backgroundImageView = UIImageView(frame: bgView.bounds)
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            bgView.addSubview(backgroundImageView)
            
            loadImage(
                into: backgroundImageView,
                urlString: place.imageURL,
            )
            
            navigationController.view.addSubview(bgView)
            
            UIView.animate(withDuration: 0.5) {
                bgView.alpha = 1
            }
            
            // delegate 설정
            nav.presentationController?.delegate = self
            nav.isNavigationBarHidden = true
            navigationController.present(nav, animated: true)
        }
    }
}

final class ProfileCoordinator: NSObject, Coordinator, CardDetailCoordinating, UIAdaptivePresentationControllerDelegate {
    private weak var sheetNav: UINavigationController?
    private weak var backdropView: UIView?
    private var place: Place?
    var onPlaceSheetDismiss: (() -> Void)?
    
    func didTapCell(place: Place) {
        self.place = place
        navigate(to: .cardDetail)
    }
    
    func didTapPlaceMarker(place: Place, onDismiss: @escaping () -> Void) {  }
    
    func didTapReviewButton() {  }
    
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
    
    func didTapEditProfile(with user: User) {
        let vc = ModuleFactory.shared.makeProfileEditVC()
        vc.coordinator = self
        vc.configure(user: user)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
        navigationController.isNavigationBarHidden = true
    }
    
    func didTapSetting() {
        navigate(to: .setting)
    }
    
    func didTapMapViewButton(place: Place) {
        dissmissPlaceSheet()
        (parentCoordinator as? MainTabCoordinator)?.openMap(place: place)
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        cleanupSheetBackdrop()     // 애니메이션 포함()
    }
    
    func dissmissPlaceSheet() {
        // 시트가 떠 있으면 닫고 completion에서 클린업
        if let presented = navigationController.presentedViewController {
            presented.dismiss(animated: true) { [weak self] in
                self?.cleanupSheetBackdrop()
            }
        } else {
            cleanupSheetBackdrop()
        }
    }
    
    private func normalizeNaverNewsImageURL(_ urlString: String?) -> URL? {
        guard var s = urlString, !s.isEmpty else { return nil }
        
        // http → https
        if s.hasPrefix("http://") {
            s = "https://" + s.dropFirst(7)
        }
        
        guard var comp = URLComponents(string: s) else { return nil }
        
        // imgnews.naver.net → imgnews.pstatic.net (호스트 불일치 해결)
        if let host = comp.host, host == "imgnews.naver.net" {
            comp.host = "imgnews.pstatic.net"
        }
        
        return comp.url
    }
    
    func loadImage(into imageView: UIImageView, urlString: String?) {
        imageView.image = UIImage(named: "placeholder")
        
        guard let url = normalizeNaverNewsImageURL(urlString) else { return }
        
        var req = URLRequest(url: url,
                             cachePolicy: .returnCacheDataElseLoad,
                             timeoutInterval: 15)
        
        // 가끔 UA 필요할 때가 있어 기본 UA 부여
        req.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile",
                     forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err {
                print("❌ Image load failed:", err.localizedDescription)
                return
            }
            if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                print("❌ HTTP \(http.statusCode) for \(url)")
                return
            }
            guard let data = data, let img = UIImage(data: data) else {
                print("❌ Decode failed")
                return
            }
            DispatchQueue.main.async {
                imageView.image = img
            }
        }.resume()
    }
    
    private func cleanupSheetBackdrop(animated: Bool = true) {
        // 백드롭 제거
        if let bg = backdropView {
            let remove: () -> Void = { [weak self] in
                bg.removeFromSuperview()
                self?.backdropView = nil
            }
            if animated {
                UIView.animate(withDuration: 0.25, animations: { bg.alpha = 0 }) { _ in remove() }
            } else {
                remove()
            }
        }

        // 상태 정리
        onPlaceSheetDismiss?()
        onPlaceSheetDismiss = nil
        place = nil
        ModuleFactory.shared.removeViewModel(for: .cardDetail)
    }
    private enum Route {
        case home
        case editProfile
        case setting
        case accountSetting
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
            
        case .cardDetail:
            guard let place else { return }
            
            let vc = ModuleFactory.shared.makeCardDetailVC(place: place)
            vc.coordinator = self as CardDetailCoordinating
            vc.view.backgroundColor = .clear
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            nav.view.backgroundColor = .clear
            
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.custom { $0.maximumDetentValue * 0.98 }]
                sheet.prefersGrabberVisible = false
            }
            
            // 블러
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            blur.frame = nav.view.bounds
            blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            nav.view.insertSubview(blur, at: 0)
            
            // ✅ 델리게이트는 'present' 전에 걸어도 OK, 혹시 몰라 두 군데 모두
            vc.presentationController?.delegate = self
            nav.presentationController?.delegate = self
            
            // ✅ (중복 생성 방지) 기존 백드롭이 있다면 먼저 제거
            cleanupSheetBackdrop(animated: false)
            
            // ✅ 백드롭 생성 & 참조 저장
            let bgView = UIView(frame: navigationController.view.bounds)
            bgView.backgroundColor = .black
            bgView.alpha = 0
            bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let backgroundImageView = UIImageView(frame: bgView.bounds)
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            bgView.addSubview(backgroundImageView)
            
            navigationController.view.addSubview(bgView)
            self.backdropView = bgView
            self.sheetNav = nav
            
            // 이미지 로드 (비동기 완료 전에 dismiss될 수도 있으니 weak 처리)
            loadImage(into: backgroundImageView, urlString: place.imageURL)
            
            UIView.animate(withDuration: 0.5) { bgView.alpha = 1 }
            
            nav.isNavigationBarHidden = true
            navigationController.present(nav, animated: true)
        }
    }
}
