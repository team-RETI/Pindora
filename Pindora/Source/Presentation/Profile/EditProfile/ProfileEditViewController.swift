//
//  ProfileViewController.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//
import UIKit

protocol ProfileEditViewControllerDelegate: AnyObject {
    ///화면이동
    func backButtonTapped()
    /// 화면이동
    func didTapRegisterButton()
}

final class ProfileEditViewController: UIViewController {
    weak var delegate: ProfileEditViewControllerDelegate?
    
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
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ProfileEditViewController")
    }

    // MARK: - Bindings
    private func bindViewModel() {

    }
    
    @objc private func didTapRegisterButton() {
        delegate?.didTapRegisterButton()
    }
    
    @objc private func backButtonTapped() {
        delegate?.backButtonTapped()
    }
}
