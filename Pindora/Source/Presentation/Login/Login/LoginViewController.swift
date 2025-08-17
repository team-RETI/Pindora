//  LoginViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import AuthenticationServices
import Combine

final class LoginViewController: UIViewController {
    private let viewModel: LoginViewModel
    private let customView = LoginView()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func loadView() {
        self.view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        print("로그인 화면")
        customView.appleLoginButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
    }
    
    @objc func appleLoginTapped() {
        viewModel.loginWithApple(from: self)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("로그인 실패: \(error.localizedDescription)")
                }
            } receiveValue: { user in
                print("유저 로그인 성공: \(user)")
                self.viewModel.saveUser(user)
                    .sink { completion in
                        if case let .failure(error) = completion {
                            print("유저 저장 실패: \(error.localizedDescription)")
                        }
                    } receiveValue: { print("유저 저장 완료")}
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }

    // MARK: - Bindings
    private func bindViewModel() {

    }
}

#Preview {
    LoginViewController(
        viewModel: LoginViewModel(
            authUseCase: StubAuthUseCaseImpl(),
            userUseCase: StubUserUseCaseImpl()
        )
    )
}
