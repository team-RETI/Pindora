//
//  PersonaInfoCardView.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//

import UIKit

final class PersonaInfoCardView: UIView {

    // 🔒 자물쇠 + 안내 문구
    private let lockImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "lock.fill"))
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 15),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
        return imageView
    }()

    private let lockLabel: UILabel = {
        let fullText = "다시 생성하려면 Ply가 더 필요합니다"
        let boldText = "Ply"
        let attributed = NSMutableAttributedString(string: fullText, attributes: [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ])
        if let range = fullText.range(of: boldText) {
            attributed.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 12), range: NSRange(range, in: fullText))
        }

        let label = UILabel()
        label.attributedText = attributed
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var lockStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [lockImageView, lockLabel])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // 📦 회색 박스 안의 제목 + 설명
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.text = "즉흥적인 도시 탐험가"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = .black
        label.text = "조용한 카페를 선호하고 갑작스럽게 화장실을 자주가며 고즈넉한 장소를 자주 방문하여 쉬어가는 라이프 스타일을 가지고 있어요"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let cardBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.93, alpha: 1.0)
        view.layer.cornerRadius = 18
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(lockStackView)
        containerView.addSubview(cardBackgroundView)
        cardBackgroundView.addSubview(titleLabel)
        cardBackgroundView.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            lockStackView.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            lockStackView.centerXAnchor.constraint(equalTo: centerXAnchor),

            cardBackgroundView.topAnchor.constraint(equalTo: lockStackView.bottomAnchor, constant: 11),
            cardBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 13),
            cardBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -13),
            cardBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),

            titleLabel.topAnchor.constraint(equalTo: cardBackgroundView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardBackgroundView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardBackgroundView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 11),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: cardBackgroundView.bottomAnchor, constant: -10)
        ])
    }
}

extension PersonaInfoCardView {
    func setPersona(name: String, description: String) {
        titleLabel.text = name
        descriptionLabel.text = description
    }
}
