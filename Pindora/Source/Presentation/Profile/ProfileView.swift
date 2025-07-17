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
    
    // MARK: - UI Component
    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "profileMemoji"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let profileTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "즉흥적인 도시 탐험가"
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let profileDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "조용한 카페를 선호하고 감각스럽게 화장실을 자주가며 고즈넉한 장소를 자주 방문하여 쉬어가는 라이프 스타일을 가지고 있어요"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var statsStackView: UIStackView = {
        let labels = [
            makeStatView(title: "스크랩한 장소", count: 136),
            makeStatView(title: "방문한 장소", count: 101),
            makeStatView(title: "좋아하는 장소", count: 72)
        ]
        let stack = UIStackView(arrangedSubviews: labels)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private let editProfileButton = makeRoundedButton(title: "프로필 수정")
    private let settingsButton = makeRoundedButton(title: "사용자 설정")
    
    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "내가 저장한 장소"
        label.font = .boldSystemFont(ofSize: 17)
        label.backgroundColor = .black
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 12
        let itemSize = (UIScreen.main.bounds.width - spacing * 4) / 3
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ProfilePlaceCellView.self, forCellWithReuseIdentifier: "PlaceCell")
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private var savedPlaceImages: [UIImage] = ["경복궁","경복궁고화질","남산타워","서울역","스타필드 시청","스타필드","여의도 한강공원","경복궁","경복궁고화질","남산타워","서울역","스타필드 시청","스타필드","여의도 한강공원"].compactMap { UIImage(named: $0) }
    
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - (F)UI Setup
    private func setupUI() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [profileImageView, profileTitleLabel, profileDescriptionLabel, statsStackView,
         editProfileButton, settingsButton, sectionTitleLabel, collectionView]
            .forEach { contentView.addSubview($0); $0.translatesAutoresizingMaskIntoConstraints = false }
        
        
    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            profileTitleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            profileTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            profileDescriptionLabel.topAnchor.constraint(equalTo: profileTitleLabel.bottomAnchor, constant: 8),
            profileDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            statsStackView.topAnchor.constraint(equalTo: profileDescriptionLabel.bottomAnchor, constant: 20),
            statsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statsStackView.heightAnchor.constraint(equalToConstant: 60),
            
            editProfileButton.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 20),
            editProfileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            
            settingsButton.topAnchor.constraint(equalTo: editProfileButton.topAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            sectionTitleLabel.topAnchor.constraint(equalTo: editProfileButton.bottomAnchor, constant: 32),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sectionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            sectionTitleLabel.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 700),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private static func makeRoundedButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .black
        button.tintColor = .white
        button.layer.cornerRadius = 14
        button.frame = button.frame.inset(by: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        return button
    }

    private func makeStatView(title: String, count: Int) -> UIView {
        let countLabel = UILabel()
        countLabel.text = "\(count)"
        countLabel.font = .boldSystemFont(ofSize: 17)
        countLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [countLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4

        let container = UIView()
        container.layer.borderColor = UIColor.black.cgColor
        container.layer.borderWidth = 1
        container.layer.cornerRadius = 16
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])

        return container
    }
}


extension ProfileView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPlaceImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceCell", for: indexPath) as? ProfilePlaceCellView else {
            print("여기 오나요?2")
            return UICollectionViewCell()
        }
        print("여기 오나요?")
        cell.configure(with: savedPlaceImages[indexPath.item])
        return cell
    }
}
