//
//  HomeView.swift
//  Pindora
//
//  Created by eunchanKim on 7/17/25.
//

import UIKit

// MARK: -(c)HomeView
final class HomeView: UIView {
    
    private let searchBarView = SearchBarView()
    let categoryListView = CategoryCellListView()
    private let sortButton = UIButton()
    let placeListView = CardCellListView()
    
    // MARK: - UI Component
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "어떤 장소가 필요하세요?"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let recommendLabel: UILabel = {
       let label = UILabel()
        label.text = "장소추천"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private let buttonLabel: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "정렬버튼")
        config.imagePlacement = .trailing
        config.imagePadding = 4 // 텍스트-이미지 간 간격
        config.baseForegroundColor = .black

        // 텍스트 크기 조절
        let font = UIFont.systemFont(ofSize: 12, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        config.attributedTitle = AttributedString("거리순", attributes: AttributeContainer(attributes))

        // 구성 적용
        button.configuration = config
        return button
    }()
    
    private let blackHeaderContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.clipsToBounds = false
        return view
    }()
    
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
        
        addSubview(blackHeaderContainerView)
        blackHeaderContainerView.addSubview(headerLabel)
        blackHeaderContainerView.addSubview(searchBarView)
        blackHeaderContainerView.addSubview(categoryListView)
        
        addSubview(recommendLabel)
        addSubview(buttonLabel)
        addSubview(sortButton)
        addSubview(placeListView)
    }
    
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        categoryListView.translatesAutoresizingMaskIntoConstraints = false
        blackHeaderContainerView.translatesAutoresizingMaskIntoConstraints = false
        recommendLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonLabel.translatesAutoresizingMaskIntoConstraints = false
//        sortButton.translatesAutoresizingMaskIntoConstraints = false
        placeListView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 검정 컨테이너
            blackHeaderContainerView.topAnchor.constraint(equalTo: topAnchor),
            blackHeaderContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blackHeaderContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blackHeaderContainerView.bottomAnchor.constraint(equalTo: categoryListView.bottomAnchor, constant: 20),
            
            headerLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: blackHeaderContainerView.centerXAnchor),
            
            searchBarView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 19),
            searchBarView.leadingAnchor.constraint(equalTo: blackHeaderContainerView.leadingAnchor, constant: 16),
            searchBarView.trailingAnchor.constraint(equalTo: blackHeaderContainerView.trailingAnchor, constant: -16),
            searchBarView.heightAnchor.constraint(equalToConstant: 34),
            
            categoryListView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: 26),
            categoryListView.leadingAnchor.constraint(equalTo: blackHeaderContainerView.leadingAnchor),
            categoryListView.trailingAnchor.constraint(equalTo: blackHeaderContainerView.trailingAnchor),
            categoryListView.heightAnchor.constraint(equalToConstant: 30),
            
            // 추천 라벨, 정렬 버튼
            recommendLabel.topAnchor.constraint(equalTo: blackHeaderContainerView.bottomAnchor, constant: 20),
            recommendLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            buttonLabel.centerYAnchor.constraint(equalTo: recommendLabel.centerYAnchor),
            buttonLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // 장소 리스트 뷰
            placeListView.topAnchor.constraint(equalTo: recommendLabel.bottomAnchor, constant: 12),
            placeListView.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeListView.trailingAnchor.constraint(equalTo: trailingAnchor),
            placeListView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

