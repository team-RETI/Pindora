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
    private let personaInfoCardView = PersonaInfoCardView()
    private let personaPreviewView = PersonaPreviewView()
    let navigationBarView = CustomNavBarView(title: "프로필 수정")
    private let contentView = UIView()

    private let imageLabel: UILabel = {
        let label = UILabel()
        label.text = "대표 이미지"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let personaTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "페르소나"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let previewLabel: UILabel = {
        let label = UILabel()
        label.text = "미리보기"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인 및 등록", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
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
        addSubview(navigationBarView)
        navigationBarView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        [imageLabel, imageSelectorView, personaTitleLabel, personaInfoCardView, previewLabel, personaPreviewView, registerButton]
            .forEach { contentView.addSubview($0); $0.translatesAutoresizingMaskIntoConstraints = false }

    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            navigationBarView.topAnchor.constraint(equalTo: topAnchor),
            navigationBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBarView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 44),
            
            contentView.topAnchor.constraint(equalTo: navigationBarView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
            
            imageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            imageSelectorView.topAnchor.constraint(equalTo: imageLabel.bottomAnchor, constant: 20),
            imageSelectorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageSelectorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageSelectorView.heightAnchor.constraint(equalToConstant: 120),

            personaTitleLabel.topAnchor.constraint(equalTo: imageSelectorView.bottomAnchor, constant: 30),
            personaTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            personaInfoCardView.topAnchor.constraint(equalTo: personaTitleLabel.bottomAnchor, constant: 10),
            personaInfoCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            personaInfoCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            personaInfoCardView.heightAnchor.constraint(equalToConstant: 120),
            
            previewLabel.topAnchor.constraint(equalTo: personaInfoCardView.bottomAnchor, constant: 30),
            previewLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            personaPreviewView.topAnchor.constraint(equalTo: previewLabel.bottomAnchor, constant: 15),
            personaPreviewView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            personaPreviewView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            personaPreviewView.heightAnchor.constraint(equalToConstant: 80),
            
            registerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            registerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            registerButton.heightAnchor.constraint(equalToConstant: 50),
            registerButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35)
        ])
    }
}
