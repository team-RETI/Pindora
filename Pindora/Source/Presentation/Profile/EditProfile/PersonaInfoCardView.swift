//
//  PersonaInfoCardView.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//

import UIKit

final class PersonaInfoCardView: UIView {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .lightGray.withAlphaComponent(0.2)
        layer.cornerRadius = 12

        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.text = "즉흥적인 도시 탐험가"
        titleLabel.textColor = .black
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .black
        descriptionLabel.text = "조용한 카페를 선호하고 갑작스럽게 화장실을 자주가며 고즈넉한 장소를 자주 방문하여 쉬어가는 라이프 스타일을 가지고 있어요"

        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 8

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
