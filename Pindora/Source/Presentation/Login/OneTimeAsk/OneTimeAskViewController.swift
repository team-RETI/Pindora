//  OneTimeAskViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

final class OneTimeAskViewController: UIViewController {
    weak var coordinator: LoginFlowCoordinator?
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
        customView.registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        bindViewModel()
        print("OTA 화면")
    }

    // MARK: - Bindings
    private func bindViewModel() {

    }
    
    @objc private func registerButtonTapped() {
        print("tapped")
//        coordinator?.done()
    }
}

