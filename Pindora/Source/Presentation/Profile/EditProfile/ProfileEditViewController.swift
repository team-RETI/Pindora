//
//  ProfileViewController.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//
import UIKit

final class ProfileEditViewController: UIViewController {
    weak var coordinator: ProfileCoordinator?
    private let viewModel: ProfileEditViewModel
    private let customView = ProfileEditView()

    // MARK: - Initializer
    init(viewModel: ProfileEditViewModel) {
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
        customView.registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        customView.imageSelectorView.memojiOverlay.addTarget(self, action: #selector(memojiTapped), for: .touchUpInside)
        customView.imageSelectorView.customOverlay.addTarget(self, action: #selector(customTapped), for: .touchUpInside)
        customView.imageSelectorView.colorOverlay.addTarget(self, action: #selector(colorTapped), for: .touchUpInside)
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ProfileEditViewController")
    }

    // MARK: - Bindings
    private func bindViewModel() {

    }
    
    @objc private func memojiTapped() {
        updateSelection(selected: customView.imageSelectorView.memojiOverlay)
    }

    @objc private func customTapped() {
        updateSelection(selected: customView.imageSelectorView.customOverlay)
    }

    @objc private func colorTapped() {
        updateSelection(selected: customView.imageSelectorView.colorOverlay)
    }

    private func updateSelection(selected: SelectableOverlayView) {
        [ customView.imageSelectorView.memojiOverlay, customView.imageSelectorView.customOverlay, customView.imageSelectorView.colorOverlay].forEach { $0.isSelected = false }
        selected.isSelected = true
    }
    
    @objc private func didTapRegisterButton() {
        coordinator?.didTapRegisterButton()
    }
    
    @objc private func backButtonTapped() {
        coordinator?.backButtonTapped()
    }
}
