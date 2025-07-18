//
//  SceneDelegate.swift
//  Pindora
//
//  Created by eunchanKim on 7/10/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    // 앱 실행 직후 (Scene 연결 시 호출됨)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // 0. 공유된 값을 가져오기
        checkSharedContent()
        
        // 0. DIContainer 초기 설정
        DIContainer.config()
        
        // 1. scene 캡처
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 2. window scene을 가져오는 windowScene을 생성자를 사용해서 UIWindow를 생성
        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        
        // 3. 로그인 여부 확인(일단 하드코딩)
        let isLoggedIn: Bool = true
        let coordinator = AppCoordinator(navigationController: navigationController, isLoggedIn: isLoggedIn)
        self.appCoordinator = coordinator
        coordinator.start()
        
        // 4. navigationController로 window의 root view controller를 설정
        window.rootViewController = navigationController
        
        // 5. window를 설정하고 makeKeyAndVisible()
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    // 백그라운드 → 포그라운드 진입 시 호출
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        // 0. 공유된 값을 가져오기
        checkSharedContent()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

extension SceneDelegate {
    // ✅ 공유된 값을 가져오는 공통 함수
    private func checkSharedContent() {
        if let sharedText = UserDefaultsManager.get(for: .sharedText) {
            print("✅ 공유된 텍스트: \(sharedText)")
        }

        if let sharedURL = UserDefaultsManager.get(for: .sharedURL) {
            print("✅ 공유된 URL: \(sharedURL)")
        }
    }
}
