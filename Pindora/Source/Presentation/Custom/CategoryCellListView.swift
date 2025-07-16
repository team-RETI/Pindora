//
//  CategoryCellListView.swift
//  Pindora
//
//  Created by eunchanKim on 7/16/25.
//

import UIKit

class CategoryCellListView: UIScrollView {
    
    private let categories = ["도서관", "카페", "관광지", "식당", "숙소", "기타", "도서관", "카페", "관광지", "식당", "숙소", "기타"]

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        showsHorizontalScrollIndicator = false
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
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
