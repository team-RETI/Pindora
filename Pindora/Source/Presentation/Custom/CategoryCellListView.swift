//
//  CategoryCellListView.swift
//  Pindora
//
//  Created by eunchanKim on 7/16/25.
//

import UIKit

final class CategoryCellListView: UIScrollView {
    
    // MARK: - UI Component
    // 더미 데이터 (ViewModel 구현후 없앨예정)
    private let categories = ["도서관", "카페", "관광지", "식당", "숙소", "기타", "도서관", "카페", "관광지", "식당", "숙소", "기타"]

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        return sv
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        showsHorizontalScrollIndicator = false
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - (F)UI Setup
    private func setupUI() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: 1),
            stackView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: -1),
            stackView.heightAnchor.constraint(equalTo: heightAnchor)
        ])

        categories.forEach { category in
            let cell = CategoryCellVeiw(title: category)
            stackView.addArrangedSubview(cell)
        }
    }
}
