//  ProfileViewView.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

// MARK: - (C)ProfileView
final class ProfileView: UIView {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let collectionView = ProfilePlaceCellListView()
    
    // MARK: - UI Component
    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "아바타"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let profileTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "즉흥적인 도시 탐험가"
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    private let profileDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "조용한 카페를 선호하고 감각스럽게 화장실을 자주가며 고즈넉한 장소를 자주 방문하여 쉬어 가는 라이프 스타일을 가지고 있어요"
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var profileStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [profileTitleLabel, profileDescriptionLabel])
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    private lazy var statsStackView: UIStackView = {
        let labels = [
            UIView.makeStatView(title: "스크랩한 장소", count: 136),
            UIView.makeStatView(title: "방문한 장소", count: 101),
            UIView.makeStatView(title: "좋아하는 장소", count: 72)
        ]
        let stack = UIStackView(arrangedSubviews: labels)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.layer.borderColor = UIColor.black.cgColor
        stack.layer.borderWidth = 1
        stack.layer.cornerRadius = 25
        return stack
    }()
    
    private let editProfileButton = UIButton.setRoundedStyle(title: "프로필 수정")
    private let settingsButton = UIButton.setRoundedStyle(title: "사용자 설정")
    
    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "내가 저장한 장소"
        label.font = .boldSystemFont(ofSize: 17)
        label.backgroundColor = .black
        label.textColor = .white
        label.textAlignment = .center
        return label
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
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        [profileImageView, profileTitleLabel, profileDescriptionLabel, profileStackView, statsStackView,
         editProfileButton, settingsButton, sectionTitleLabel]
            .forEach { contentView.addSubview($0); $0.translatesAutoresizingMaskIntoConstraints = false }

        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            contentView.bottomAnchor.constraint(equalTo: sectionTitleLabel.topAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 7),
            profileImageView.widthAnchor.constraint(equalToConstant: 82.75),
            profileImageView.heightAnchor.constraint(equalToConstant: 82.75),
            
            profileStackView.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            profileStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            profileStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -7),
            
            profileTitleLabel.topAnchor.constraint(equalTo: profileStackView.topAnchor),
            profileTitleLabel.leadingAnchor.constraint(equalTo: profileStackView.leadingAnchor),
            profileTitleLabel.trailingAnchor.constraint(equalTo: profileStackView.trailingAnchor),
            
            profileDescriptionLabel.topAnchor.constraint(equalTo: profileTitleLabel.bottomAnchor, constant: 5),
            profileDescriptionLabel.leadingAnchor.constraint(equalTo: profileStackView.leadingAnchor),
            profileDescriptionLabel.trailingAnchor.constraint(equalTo: profileStackView.trailingAnchor),
                        
            statsStackView.topAnchor.constraint(equalTo: profileDescriptionLabel.bottomAnchor, constant: 20),
            statsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            statsStackView.heightAnchor.constraint(equalToConstant: 72),
            
            editProfileButton.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 15),
            editProfileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            editProfileButton.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -10),
            editProfileButton.widthAnchor.constraint(equalTo: settingsButton.widthAnchor),
          
            settingsButton.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 15),
            settingsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            sectionTitleLabel.topAnchor.constraint(equalTo: editProfileButton.bottomAnchor, constant: 20),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            sectionTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            sectionTitleLabel.heightAnchor.constraint(equalToConstant: 43),
            
            scrollView.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
