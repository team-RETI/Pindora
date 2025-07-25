//
//  PersonaPreviewView.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//

import UIKit

final class PersonaPreviewView: UIView {
    private let avatarImageView = UIImageView()
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
        avatarImageView.image = UIImage(named: "memoji_sample")
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .boldSystemFont(ofSize: 15)
        titleLabel.text = "즉흥적인 도시 탐험가"
        titleLabel.textColor = .black
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .black
        descriptionLabel.text = "조용한 카페를 선호하고 갑작스럽게 화장실을 자주가며 고즈넉한 장소를 자주 방문하여 쉬어가는 라이프 스타일을 가지고 있어요"


        addSubview(avatarImageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)

        avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
    }
}
