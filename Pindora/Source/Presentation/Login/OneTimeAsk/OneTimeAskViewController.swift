//  OneTimeAskViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

final class OneTimeAskViewController: UIViewController {
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

    }
}

#Preview {
    OneTimeAskViewController(viewModel: LoginViewModel(authUseCase: StubAuthUseCaseImpl()))
}
