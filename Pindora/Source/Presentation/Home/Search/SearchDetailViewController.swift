//  SearchViewController.swift
//  Pindora
//
//  Created by 김동현 on 9/5/25.
//

import UIKit

final class SearchDetailViewController: UIViewController {
    private let viewModel: HomeViewModel
    private let customView = SearchDetailView()
    
    // MARK: - Initializer
    init(viewModel: HomeViewModel) {
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

    // MARK: - Bindings
    private func bindViewModel() {

    }
}

#Preview {
    SearchDetailViewController(viewModel: HomeViewModel(placeUseCase: PlaceUseCaseImpl(repository: DatabaseRepositoryImpl())))
}
