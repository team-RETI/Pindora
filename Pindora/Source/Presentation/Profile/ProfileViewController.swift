//  ProfileViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine
import Kingfisher

final class ProfileViewController: UIViewController {
    weak var coordinator: ProfileCoordinator?
    private let viewModel: ProfileViewModel
    private let customView = ProfileView()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Subjects (Input source)
    private let reloadSubject = PassthroughSubject<Void, Never>()
    
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
        customView.gptRefreshButton.addTarget(self, action: #selector(gptRefreshTapped), for: .touchUpInside)
        bindViewModel()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshProfile), name: .profileUpdated, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ProfileViewController")
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        let input = ProfileViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            reload: reloadSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if let user = user {
                    self?.customView.setProfileTitleLabel(user.personaName)
                    self?.customView.setProfileDescriptionLabel(user.personaDescription)
                    if let urlString = user.userImage, let url = URL(string: urlString) {
                        self?.loadImage(from: url)
                    }
                    let saved = user.savedPlaces.count
                    let visited = user.visitedPlaces.count
                    let liked = user.likedPlaces.count
                    self?.customView.updatePlaceCount(saved: saved, visited: visited, liked: liked)
                }
            }
            .store(in: &cancellables)
        
        // 장소 렌더링
        output.places
            .receive(on: DispatchQueue.main)
            .sink { [weak self] places in
                self?.customView.updatePlaceLog(places)
            }
            .store(in: &cancellables)
        
//        viewModel.$user
//            .compactMap { $0 }
//            .receive(on: RunLoop.main)
//            .sink { [weak self] (user: User) in
//                self?.customView.setProfileTitleLabel(user.personaName)
//                self?.customView.setProfileDescriptionLabel(user.personaDescription)
//                if let urlString = user.userImage, let url = URL(string: urlString) {
//                    self?.loadImage(from: url)
//                }
//                
//                let saved = user.savedPlaces.count
//                let visited = user.visitedPlaces.count
//                let liked = user.likedPlaces.count
//                
//                self?.customView.updatePlaceCount(saved: saved, visited: visited, liked: liked)
//                self?.customView.updatePlaceLog(user.visitedPlaces)
//            }
//            .store(in: &cancellables)
    }
    
    private func loadImage(from url: URL) {
        customView.setProfileImage(from: url)
    }
    
    // 버튼 탭 처리
    @objc private func editProfileButtonTapped() {
        guard let user = viewModel.user else {
            print("현재 유저 x")
            return
        }
        coordinator?.didTapEditProfile(with: user)
    }
    @objc private func settingsButtonTapped() {
        coordinator?.didTapSetting()
    }
    
    @objc private func gptRefreshTapped() {
        let keyword = ["청계천", "망원한강공원", "카페 어니언 안국점", "한국은행 본점", "국회의사당", "서울대학교", "롯데월드타워", "김포공항"]
        viewModel.generatePersona(for: keyword)
    }
    
    @objc private func refreshProfile() {
        viewModel.loadUser()
    }
}

