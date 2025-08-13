//
//  ProfileEditView.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//

import UIKit

// MARK: - (C)ProfileEditView
final class ProfileEditView: UIView {
    let imageSelectorView = ImageSelectorView()
    private let personaInfoCardView = PersonaInfoCardView()
    private let personaPreviewView = PersonaPreviewView()
    let navigationBarView = CustomNavBarView(title: "프로필 수정")
    private let contentView = UIView()

    private let imageTitleLabel = UILabel.makeTitleLabel(text: "대표 이미지")
    private let personaTitleLabel = UILabel.makeTitleLabel(text: "페르소나")
    
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인 및 등록", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 18
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private lazy var titleInfoStackView: UIStackView = {
        let infoImage = UIImageView(image: UIImage(named: "infoImage"))
        infoImage.contentMode = .scaleAspectFit
        infoImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            infoImage.widthAnchor.constraint(equalToConstant: 15),
            infoImage.heightAnchor.constraint(equalToConstant: 15)
        ])
        let imageInfoLabel = UILabel.makeSubInfoLabel(text: "Memoji는 직접 생성 해야합니다")
        let stackView = UIStackView(arrangedSubviews: [infoImage, imageInfoLabel])
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()
    
    private lazy var personaInfoStackView: UIStackView = {
        let image = UIImageView(image: UIImage(named: "infoImage"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 15),
            image.heightAnchor.constraint(equalToConstant: 15)
        ])
        let personaInfoLabel = UILabel.makeSubInfoLabel(text: "저장한 장소 및 좋아하는 장소를 통해 나만의 페르소나를 생성")
        let stackView = UIStackView(arrangedSubviews: [image, personaInfoLabel])
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()
    
    private lazy var previewStackView: UIStackView = {
        let image = UIImageView(image: UIImage(named: "미리보기"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 30),
            image.heightAnchor.constraint(equalToConstant: 30),
        ])
        let previewLabel = UILabel.makeTitleLabel(text: "미리보기")
        let stackView = UIStackView(arrangedSubviews: [image, previewLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 14
        return stackView
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
    
    // MARK: - (F)UI Setup
    private func setupUI() {
        backgroundColor = .white
        addSubview(navigationBarView)
        navigationBarView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        [imageTitleLabel,titleInfoStackView, imageSelectorView, personaTitleLabel, personaInfoStackView, personaInfoCardView, previewStackView, personaPreviewView, registerButton]
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
            
            imageTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 23),
            imageTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleInfoStackView.topAnchor.constraint(equalTo: imageTitleLabel.bottomAnchor,constant: 8),
            titleInfoStackView.leadingAnchor.constraint(equalTo: imageTitleLabel.leadingAnchor),
            
            imageSelectorView.topAnchor.constraint(equalTo: titleInfoStackView.bottomAnchor, constant: 10),
            imageSelectorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 13),
            imageSelectorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -13),
            imageSelectorView.heightAnchor.constraint(equalToConstant: 160),

            personaTitleLabel.topAnchor.constraint(equalTo: imageSelectorView.bottomAnchor, constant: 20),
            personaTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            personaInfoStackView.topAnchor.constraint(equalTo: personaTitleLabel.bottomAnchor,constant: 8),
            personaInfoStackView.leadingAnchor.constraint(equalTo: personaTitleLabel.leadingAnchor),
            
            personaInfoCardView.topAnchor.constraint(equalTo: personaInfoStackView.bottomAnchor, constant: 10),
            personaInfoCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 13),
            personaInfoCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -13),
            personaInfoCardView.heightAnchor.constraint(equalToConstant: 140),
            
            previewStackView.topAnchor.constraint(equalTo: personaInfoCardView.bottomAnchor, constant: 14),
            previewStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            previewStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            previewStackView.heightAnchor.constraint(equalToConstant: 75),
            
            personaPreviewView.topAnchor.constraint(equalTo: previewStackView.bottomAnchor, constant: 27),
            personaPreviewView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            personaPreviewView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 42),
            personaPreviewView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -42),
            
            registerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            registerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            registerButton.heightAnchor.constraint(equalToConstant: 50),
            registerButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35)
        ])
    }
}
