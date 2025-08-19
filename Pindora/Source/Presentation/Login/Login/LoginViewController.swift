//  LoginViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine
import CombineCocoa

final class LoginViewController: UIViewController {
    weak var coordinator: LoginCoordinator?
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: LoginViewModel
    private let customView = LoginView()
    
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
    }

    // MARK: - Bindings
    private func bindViewModel() {
        let input = LoginViewModel.Input(appleLoginTapped: customView.appleLoginButton.tapPublisher.eraseToAnyPublisher())
        
        let output = viewModel.transform(input: input)
        
        output.loginResult
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                switch result {
                case .success:
                    print("✅ 애플 로그인 성공")
                    self?.coordinator?.didTapLoginButton()
                case .failure(let error):
                    // print("❌ 애플 로그인 실패:", error.localizedDescription)
                    printFullErrorTrace(error: error)
                }
            }
            .store(in: &cancellables)
    }
}

#Preview {
    LoginViewController(viewModel: LoginViewModel(authUseCase: StubAuthUseCaseImpl(), userUseCase: StubUserUsecaseImpl()))
}







