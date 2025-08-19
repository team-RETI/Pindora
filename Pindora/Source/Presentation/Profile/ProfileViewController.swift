//  ProfileViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine

final class ProfileViewController: UIViewController {
    weak var coordinator: ProfileCoordinator?
    private let viewModel: ProfileViewModel
    private let customView = ProfileView()
    private var cancellables = Set<AnyCancellable>()

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
        viewModel.$personaName
            .receive(on: RunLoop.main)
            .sink { [weak self] name in
                self?.customView.setProfileTitleLabel(name)
            }
            .store(in: &cancellables)
        
        viewModel.$personaDescription
            .receive(on: RunLoop.main)
            .sink { [weak self] description in
                self?.customView.setProfileDescriptionLabel(description)
            }
            .store(in: &cancellables)
        
        viewModel.$userImageURL
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] urlString in
                guard let url = URL(string: urlString) else { return }
                self?.loadImage(from: url)
            }
            .store(in: &cancellables)
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data, let image = UIImage(data: data), error == nil else {
                print("이미지 로딩 실패: \(error?.localizedDescription ?? "이미지 오류 발생")")
                return
            }
            DispatchQueue.main.async {
                self?.customView.setProfileImageView(image)
            }
        }.resume()
    }
    
    // 버튼 탭 처리
    @objc private func editProfileButtonTapped() {
        coordinator?.didTapEditProfile()
    }
    @objc private func settingsButtonTapped() {
        coordinator?.didTapSetting()
    }

}


