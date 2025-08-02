//
//  AddPlaceView.swift
//  Pindora
//
//  Created by eunchanKim on 7/28/25.
//

import UIKit

final class AddPlaceView: UIView {
    private let contentView = UIView()
    let categories = ["도서관", "카페", "관광지", "식당", "숙소", "기타", "도서관", "카페"]
    private let dummyPlace = PlaceModel(
        category: "관광지",
        likeCount: 159,
        title: "경복궁",
        description: "서울특별시 종로구 사직로 161",
        imageName: "경복궁",
        date: "2주전"
    )
    private lazy var previewCard = PreviewCardView()
    private let searchField = SearchBarView()
    // MARK: - UI 컴포넌트
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "장소 추가"
        label.font = .boldSystemFont(ofSize: 30)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white

        return button
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "가고 싶은곳, 갔었던 곳을 한 곳에 보관할 수 있습니다"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "주소"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    private lazy var previewStackView: UIStackView = {
        let image = UIImageView(image: UIImage(named: "미리보기_w"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 30),
            image.heightAnchor.constraint(equalToConstant: 30),
        ])
        let previewLabel = UILabel.makeTitleLabel(text: "미리보기")
        previewLabel.textColor = .white
        let stackView = UIStackView(arrangedSubviews: [image, previewLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 14
        return stackView
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인 및 등록", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        return button
    }()
    
    lazy var categoryViews: [CategoryCellView] = {
        return categories.map { CategoryCellView(title: $0) }
    }()
    
    lazy var categoryStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 7
        stack.backgroundColor = .white
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.layer.cornerRadius = 18
        stack.layer.masksToBounds = true
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        for i in stride(from: 0, to: categories.count, by: 4) {
            let rowViews = Array(categoryViews[i..<min(i+4, categoryViews.count)])
            
            let row = UIStackView(arrangedSubviews: rowViews)
            row.axis = .horizontal
            row.spacing = 7
            row.distribution = .fillEqually
            stack.addArrangedSubview(row)
        }
        return stack
    }()
    
    // MARK: - 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        
        previewCard.configure(with: dummyPlace)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 셋업
    private func setupUI() {
        backgroundColor = .black
        contentView.clipsToBounds = false
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        [cancelButton, titleLabel, subtitleLabel, addressLabel, searchField, categoryLabel, categoryStack, previewStackView, previewCard]
            .forEach { contentView.addSubview($0); $0.translatesAutoresizingMaskIntoConstraints = false }
        
        addSubview(confirmButton)
    }

    // MARK: - 오토레이아웃
    private func setupConstraints() {
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            contentView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 35),
            
            titleLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 7),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            addressLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 25),
            addressLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            
            searchField.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 10),
            searchField.heightAnchor.constraint(equalToConstant: 31),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            categoryLabel.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24),
            categoryLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            
            categoryStack.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor,constant: 10),
//            categoryStack.heightAnchor.constraint(equalToConstant: 90),
            categoryStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            categoryStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            previewStackView.topAnchor.constraint(equalTo: categoryStack.bottomAnchor, constant: 16),
            previewStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            previewStackView.heightAnchor.constraint(equalToConstant: 75),
            
            previewCard.topAnchor.constraint(equalTo: previewStackView.bottomAnchor, constant: 16),
            previewCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            previewCard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            previewCard.heightAnchor.constraint(equalToConstant: 190),
            
            confirmButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
            confirmButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35)
        ])
    }
}
