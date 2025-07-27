//  ProfileViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

final class ProfileViewController: UIViewController {
    weak var coordinator: ProfileCoordinator?
    private let viewModel: ProfileViewModel
    private let customView = ProfileView()

    // MARK: - Initializer
    init(viewModel: ProfileViewModel) {
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
        customView.editProfileButton.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
        customView.settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ProfileViewController")
    }

    // MARK: - Bindings
    private func bindViewModel() {

    }
    
    // 버튼 탭 처리
    @objc private func editProfileButtonTapped() {
            coordinator?.didTapEditProfile()
    }
    @objc private func settingsButtonTapped() {
            coordinator?.didTapSetting()
    }

}


