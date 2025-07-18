//
//  SearchBarView.swift
//  Pindora
//
//  Created by eunchanKim on 7/16/25.
//

import UIKit

final class SearchBarView: UIView {

    // MARK: - UI Component
    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "검색어를 입력하세요"
        tf.borderStyle = .none
        tf.clearButtonMode = .whileEditing
        tf.textColor = .black
        tf.font = .systemFont(ofSize: 16)
        
        return tf
    }()

    let micButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "mic"), for: .normal)
        button.tintColor = .systemGray
        return button
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

    // Setup
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 18
        layer.masksToBounds = true

        addSubview(iconImageView)
        addSubview(textField)
        addSubview(micButton)
    }

    private func setupConstraints() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        micButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            micButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            micButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            micButton.widthAnchor.constraint(equalToConstant: 20),
            micButton.heightAnchor.constraint(equalToConstant: 20),

            textField.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: micButton.leadingAnchor, constant: -12),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}
