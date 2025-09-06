//  SearchDetailView.swift
//  Pindora
//
//  Created by 김동현 on 9/5/25.
//

import UIKit

// MARK: - (C)SearchView
final class SearchDetailView: UIView {
    
    // MARK: - UI Component
    let searchBarView = SearchBarDetailView()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - (F)UI Setup
    private func setupUI() {
        backgroundColor = .white
        
        [searchBarView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    // MARK: - (F)Constraints
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            searchBarView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            searchBarView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            searchBarView.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}

#Preview {
    SearchDetailViewController(viewModel: HomeViewModel(placeUseCase: PlaceUseCaseImpl(repository: DatabaseRepositoryImpl())))
}
