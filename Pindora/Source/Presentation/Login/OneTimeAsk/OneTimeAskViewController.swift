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
        
        // 1. Input 생성
        let input = LoginViewModel.OTAInput(
            updateCategories: customView.registerButton.tapPublisher
                .map { [weak self] _ in
                    guard let self = self else { return [] }
                    return self.customView.selectedKeywords
                }
                .eraseToAnyPublisher()
        )
        
        // 2, ViewModel transform 호출
        let output = viewModel.transform(input: input)
        
        // 3. Output 구독
        output.categoryUpdateResult
            .sink { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.coordinator?.navigateToMainTab()
                case .failure(let error):
                    print("❌ 카테고리 업데이트 실패: \(error)")
                }
            }.store(in: &cancellables)
    }
}
