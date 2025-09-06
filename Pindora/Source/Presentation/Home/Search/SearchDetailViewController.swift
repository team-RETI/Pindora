//  SearchViewController.swift
//  Pindora
//
//  Created by 김동현 on 9/5/25.
//

import UIKit
import Combine

final class SearchDetailViewController: UIViewController {
    private let viewModel: HomeViewModel
    private let customView = SearchDetailView()
    private var cancellables = Set<AnyCancellable>()
    
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
        setButton()
    }

    // MARK: - Bindings
    private func bindViewModel() {

        // MARK: - SearchDetailView
        customView.searchBarView.textField.textPublisher
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates() // 같은 텍스트는 무시
            .sink { [weak self] query in
                guard let self = self else { return }
                let text = query ?? ""
                
                if text.isEmpty {
                    self.viewModel.resetFilter()
                } else {
                    self.viewModel.filterKeywords(query: text)
                }
            }.store(in: &cancellables)
    }
    
    private func setButton() {
        customView.searchBarView.backButtonTapped = { [weak self] in
            self?.dismiss(animated: false)
        }
    }
}

#Preview {
    SearchDetailViewController(viewModel: HomeViewModel(placeUseCase: PlaceUseCaseImpl(repository: DatabaseRepositoryImpl())))
}
