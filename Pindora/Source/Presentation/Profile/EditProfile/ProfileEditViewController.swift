//
//  ProfileViewController.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//
import UIKit
import PhotosUI
import Combine

final class ProfileEditViewController: UIViewController {
    weak var coordinator: ProfileCoordinator?
    private let viewModel: ProfileEditViewModel
    private let customView = ProfileEditView()
    private var currentUser: User?
    private var cancellables = Set<AnyCancellable>()
    
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
        viewModel.selectedImageType = .memoji
        updateSelection(selected: customView.imageSelectorView.memojiOverlay)
        
        // 미리보기 초기화
        customView.updateCustomImage(UIImage(named: "default_memoji"))
    }
    
    @objc private func customTapped() {
        viewModel.selectedImageType = .custom
        updateSelection(selected: customView.imageSelectorView.customOverlay)
        presentPhotoPicker()
    }
    
    @objc private func colorTapped() {
        updateSelection(selected: customView.imageSelectorView.colorOverlay)
        viewModel.selectedImageType = .color
        showColorPicker()
    }
    
    @objc private func didTapRegisterButton() {
        guard let user = currentUser else { return }
        
        let profileImage: UIImage?
        switch viewModel.selectedImageType {
        case .custom:
            profileImage = customView.currentCustomImage()
        case .color:
            profileImage = customView.currentColorImage()
        default:
            profileImage = nil
        }
        
        viewModel.registerProfile(user: user,
                                  customImage: profileImage)
        .sink { [weak self] _ in
            print("프로필 저장 완료")
            self?.coordinator?.backButtonTapped()
        }
        .store(in: &cancellables)
    }
    
    @objc private func backButtonTapped() {
        coordinator?.backButtonTapped()
    }
    
    private func showColorPicker() {
        let picker = UIColorPickerViewController()
        picker.delegate = self
        picker.selectedColor = viewModel.selectedColor ?? .systemBlue
        present(picker, animated: true)
    }
    
    private func updateSelection(selected: SelectableOverlayView) {
        [ customView.imageSelectorView.memojiOverlay, customView.imageSelectorView.customOverlay, customView.imageSelectorView.colorOverlay].forEach { $0.isSelected = false }
        selected.isSelected = true
    }
    
    // MARK: - function
    private func presentPhotoPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func configure(user: User) {
        self.currentUser = user
    }
}

extension ProfileEditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let self, let image = object as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    // UI 반영
                    self.customView.updateCustomImage(image)
                    // 필요하면 VM에도 저장해두기
                    // self.viewModel.selectedImageType = .custom
                    // self.viewModel.customImage = image
                }
            }
        }
    }
}

extension ProfileEditViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        viewModel.selectedColor = color
        
        let image = UIImage.fromColor(color)
        customView.updateColorImage(image)
        viewModel.selectedImageType = .color
        viewModel.selectedColor = color
    }
}
