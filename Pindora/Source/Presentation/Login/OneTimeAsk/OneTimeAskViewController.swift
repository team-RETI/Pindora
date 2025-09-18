//  OneTimeAskViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine

final class OneTimeAskViewController: UIViewController {
    weak var coordinator: LoginFlowCoordinator?
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
        print("OTA 화면")
    }

    // MARK: - Bindings
    private func bindViewModel() {
        customView.registerButton
            .tapPublisher
            .sink { [weak self] _ in
                guard let self = self else { return }
                if let coordinator = self.coordinator {
                    print("✅ coordinator 있음:", coordinator)
                    coordinator.navigateToMainTab()
                } else {
                    print("❌ coordinator is nil")
                }
                print("다음 버튼")
                print("선택된 키워드 배열", self.customView.selectedKeywords)
                viewModel.updateCategories(self.customView.selectedKeywords)
                
            }
            .store(in: &cancellables)
    }
}

#Preview {
    OneTimeAskViewController(viewModel: LoginViewModel(authUseCase: StubAuthUseCaseImpl(), userUseCase: StubUserUsecaseImpl()))
}
