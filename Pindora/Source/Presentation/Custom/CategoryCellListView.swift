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
    var categoriesDummy = ["편의점", "카페", "은행", "음식점", "약국", "주차장", "숙박", "학원", "학교", "주유소"]
    
    lazy var categories: [KakaoCategoryGroup] = {
        categoriesDummy.compactMap { KakaoCategoryGroup.from(displayName: $0) }
    }()

    lazy var categoryViews: [CategoryCellView] = {
//        categories.map { CategoryCellView(title: $0.displayName) }
        categories.map { CategoryCellView(title: $0.displayName, color: color)}
    }()
    
    lazy var categoryViews2: [CategoryCellView] = {
        categories.map { CategoryCellView(title: $0.displayName, color: color)}
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        return sv
    }()
    
    private var color: UIColor = .white
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        showsHorizontalScrollIndicator = false
        setupUI()
    }
    
    init(frame: CGRect, color: UIColor, keywords: [String] = []) {
            super.init(frame: frame)
            self.color = color
            self.categoriesDummy = keywords
            showsHorizontalScrollIndicator = false
            setupUI()
            configure(with: keywords)
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
            stackView.heightAnchor.constraint(equalTo: heightAnchor, constant: -4)
        ])

        categoryViews.forEach { category in
            stackView.addArrangedSubview(category)
        }
    }
    
    func configure(with keywords: [String]) {
        // 기존 뷰들 제거
        categoryViews.forEach { $0.removeFromSuperview() }
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        categoryViews.removeAll()

        // 새로운 키워드로 구성
        let displayKeywords = keywords.isEmpty ? ["편의점", "카페", "은행", "음식점", "약국", "주차장", "숙박", "학원", "학교", "주유소"] : keywords

        displayKeywords.forEach { keyword in
            let view = CategoryCellView(title: keyword, color: color)
            stackView.addArrangedSubview(view)
            categoryViews.append(view)
        }
    }
}

//#Preview {
//    SearchDetailViewController(viewModel: HomeViewModel(locationUseCase: LocationUseCaseImpl(),
//                                                        searchUseCase: <#T##any SearchUseCaseProtocol#>,
//                                                        imageUseCase: <#T##any ImageUsecaseProtocol#>,
//                                                        placeUseCase: <#T##any PlaceUseCase#>)
//}
