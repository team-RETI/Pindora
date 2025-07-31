//
//  AddPlaceView.swift
//  Pindora
//
//  Created by eunchanKim on 7/28/25.
//

import UIKit

final class AddPlaceView: UIView {
    
    // MARK: - UI 컴포넌트
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "장소 추가"
        label.font = .boldSystemFont(ofSize: 24)
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
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let searchField: UITextField = {
        let field = UITextField()
        field.placeholder = "주소"
        field.leftView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        field.leftViewMode = .always
        field.borderStyle = .roundedRect
        field.backgroundColor = .white
        return field
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    private let categoryButtons: [UIButton] = {
        let titles = ["도서관", "관광지", "식당", "숙소", "카페", "화장실", "공원", "기타"]
        return titles.map {
            let btn = UIButton(type: .system)
            btn.setTitle($0, for: .normal)
            btn.setTitleColor(.black, for: .normal)
            btn.backgroundColor = .white
            btn.layer.cornerRadius = 18
            btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            return btn
        }
    }()
    
    private let previewLabel: UILabel = {
        let label = UILabel()
        label.text = "미리보기"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    private let previewCard: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 18
        return view
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

    private lazy var categoryStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        for i in stride(from: 0, to: categoryButtons.count, by: 4) {
            let row = UIStackView(arrangedSubviews: Array(categoryButtons[i..<min(i+4, categoryButtons.count)]))
            row.axis = .horizontal
            row.spacing = 8
            row.distribution = .fillEqually
            stack.addArrangedSubview(row)
        }
        return stack
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            cancelButton,
            titleLabel,
            subtitleLabel,
            searchField,
            categoryLabel,
            categoryStack,
            previewLabel,
            previewCard,
            confirmButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 셋업
    private func setupUI() {
        backgroundColor = .black
        addSubview(contentStack)
    }

    // MARK: - 오토레이아웃
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            searchField.heightAnchor.constraint(equalToConstant: 44),
            previewCard.heightAnchor.constraint(equalToConstant: 180),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
