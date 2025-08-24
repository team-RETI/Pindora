//  LoginViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import Combine
import CombineCocoa
import SwiftUI
final class LoginViewController: UIViewController {
    weak var coordinator: LoginCoordinator?
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: LoginViewModel
    private var hostingController: UIHostingController<LoginView>?
    
    // 👇 SwiftUI 버튼 탭을 브리지할 Subject
    private let appleTap = PassthroughSubject<Void, Never>()

    // MARK: - Initializer
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1) SwiftUI 뷰 생성 + 콜백 주입
        let swiftUIView = LoginView(onContinue: { [weak self] in
            self?.appleTap.send()
        })

        // 2) HostingController로 감싸기
        let hosting = UIHostingController(rootView: swiftUIView)
        self.hostingController = hosting

        // 3) 자식으로 추가
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hosting.didMove(toParent: self)

        bindViewModel()
        print("로그인 화면")
    }

    // MARK: - Bindings
    private func bindViewModel() {
        let input = LoginViewModel.Input(
                    appleLoginTapped: appleTap.eraseToAnyPublisher()
                )
        let output = viewModel.transform(input: input)
        
        output.loginResult
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                switch result {
                case .success:
                    print("✅ 애플 로그인 성공")
                    self?.coordinator?.didTapLoginButton()
                case .failure(let error):
                    error.printFullTrace()
                }
            }
            .store(in: &cancellables)
    }
}
