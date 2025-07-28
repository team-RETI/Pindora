//
//  AccountSettingViewController.swift
//  Pindora
//
//  Created by eunchanKim on 7/23/25.
//

import UIKit
final class AccountSettingViewController: UIViewController {
    weak var coordinator: ProfileCoordinator?
    private let viewModel: AccountSettingViewModel
    private let customView = AccountSettingView()
    
    // MARK: - Initializer
    init(viewModel: AccountSettingViewModel) {
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
        customView.navigationBarView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customView.logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        customView.deleteAccountButton.addTarget(self, action: #selector(didTapDeleteAccount), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("AccountSettingViewController")
    }

    // MARK: - Bindings
    private func bindViewModel() {

    }
    
    @objc private func didTapLogout() {
        coordinator?.didTapLogout()
    }
    
    @objc private func didTapDeleteAccount() {
        coordinator?.didTapDeleteAccount()
    }
    
    @objc private func backButtonTapped() {
        coordinator?.backButtonTapped()
    }
}
