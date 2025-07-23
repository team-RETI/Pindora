//
//  ImageSelectorView.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//

import UIKit

final class ImageSelectorView: UIView {

    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 12

        ProfileEditViewModel.ImageType.allCases.forEach { type in
            let button = UIButton(type: .system)
            button.setTitle(type.rawValue, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.layer.cornerRadius = 12
            button.backgroundColor = .lightGray.withAlphaComponent(0.3)
            stackView.addArrangedSubview(button)
        }

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
