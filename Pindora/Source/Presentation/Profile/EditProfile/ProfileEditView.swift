//
//  ProfileEditView.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//

import UIKit

// MARK: - (C)ProfileEditView
final class ProfileEditView: UIView {
    private let imageSelectorView = ImageSelectorView()
    private let personaCardView = PersonaInfoCardView()
    private let previewView = PersonaPreviewView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 수정"
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인 및 등록", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            imageSelectorView,
            personaCardView,
            previewView,
            submitButton
        ])
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - (F)UI Setup
    private func setUI() {
        backgroundColor = .white
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }
}
