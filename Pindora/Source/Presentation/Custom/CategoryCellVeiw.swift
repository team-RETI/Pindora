//
//  CategoryCellVeiw.swift
//  Pindora
//
//  Created by eunchanKim on 7/16/25.
//

import UIKit

class CategoryCellVeiw: UIView {
    
    // MARK: - UI Component
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initializer
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - (F)UI Setup
    private func setupUI() {
        backgroundColor = .white
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
        clipsToBounds = true
        addSubview(titleLabel)
    }
    
    private func setupLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // ✅ 고정된 크기
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 70, height: 30)
    }
    
    //CornerRadius 적용
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
