//  OneTimeAskViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine

final class OneTimeAskViewController: UIViewController {
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: LoginViewModel
    private let customView = OneTimeAskView()
    
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
    }

    // MARK: - Bindings
    private func bindViewModel() {
        customView.nextButton
            .tapPublisher
            .sink { [weak self] _ in
                print("다음 버튼")
            }
            .store(in: &cancellables)
    }
}

#Preview {
    OneTimeAskViewController(viewModel: LoginViewModel(authUseCase: StubAuthUseCaseImpl(), userUseCase: StubUserUsecaseImpl()))
}
