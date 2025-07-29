//
//  AddPlaceViewController.swift
//  Pindora
//
//  Created by eunchanKim on 7/28/25.
//

import UIKit

final class AddPlaceViewController: UIViewController {
    weak var coordinator: MyPlaceCoordinator?
    private let viewModel: AddPlaceViewModel
    private let customView = AddPlaceView()
    
    // MARK: - Initializer
    init(viewModel: AddPlaceViewModel) {
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
        customView.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        customView.confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        print("AddPlaceViewController")
    }

    // MARK: - Bindings
    private func bindViewModel() {

    }
    
    @objc private func cancelButtonTapped() {
        print("cancelButtonTapped")
        dismiss(animated: true)
    }
    
    @objc private func confirmButtonTapped() {
        print("confirmButtonTapped")
        dismiss(animated: true)
    }
}
