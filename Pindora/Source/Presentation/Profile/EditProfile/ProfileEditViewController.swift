//
//  ProfileViewController.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//
import UIKit

final class ProfileEditViewController: UIViewController {
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

        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ProfileEditViewController")
    }

    // MARK: - Bindings
    private func bindViewModel() {

    }
}
