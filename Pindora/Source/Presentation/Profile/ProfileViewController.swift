//  ProfileViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

protocol ProfileViewControllerDelegate: AnyObject {
    /// 화면이동
    func didTapEditProfile()
    /// 화면이동
    func didTapSetting()
}

final class ProfileViewController: UIViewController {
    weak var delegate: ProfileViewControllerDelegate?
    
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
            delegate?.didTapEditProfile()
    }
    @objc private func settingsButtonTapped() {
            delegate?.didTapSetting()
    }

}


