//
//  PreviewCardView.swift
//  Pindora
//
//  Created by eunchanKim on 8/1/25.
//

import UIKit

final class PreviewCardView: UIView {
    
    // MARK: - UI Component
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        return imageView
    }()

    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return view
    }()
    
    private let catetoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    private let likedCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .black
        return label
    }()
    
    private let categoryIcon: UIImageView = {
        let image = UIImageView(image: UIImage(named: "태그"))
        image.tintColor = .black
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let likeIcon: UIImageView = {
        let image = UIImageView(image: UIImage(named: "좋아요"))
        image.tintColor = .black
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var tagStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [categoryIcon, catetoryLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        stackView.backgroundColor = .white
        stackView.layer.masksToBounds = true
        stackView.layer.cornerRadius = 8
        return stackView
    }()
    
    private lazy var likedCountStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [likeIcon, likedCountLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = 8
        stackView.layer.masksToBounds = true
        return stackView
    }()
    
    private let imageSelectButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.masksToBounds = false  // 그림자가 잘리지 않도록 설정
        return button
    }()
    
    private let imageInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "이미지 불러오기"
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - (F)UI Setup
    private func setupUI() {
        addSubview(thumbnailImageView)
        thumbnailImageView.addSubview(overlayView)
        thumbnailImageView.addSubview(imageSelectButton)
        thumbnailImageView.addSubview(imageInfoLabel)
        thumbnailImageView.addSubview(titleLabel)
        thumbnailImageView.addSubview(descriptionLabel)
        thumbnailImageView.addSubview(dateLabel)
        thumbnailImageView.addSubview(tagStackView)
        thumbnailImageView.addSubview(likedCountStackView)
    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        imageSelectButton.translatesAutoresizingMaskIntoConstraints = false
        imageInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        tagStackView.translatesAutoresizingMaskIntoConstraints = false
        likedCountStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            imageSelectButton.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            imageSelectButton.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor),
            imageSelectButton.widthAnchor.constraint(equalToConstant: 55),
            imageSelectButton.heightAnchor.constraint(equalToConstant: 55),
            
            imageInfoLabel.topAnchor.constraint(equalTo: imageSelectButton.bottomAnchor, constant: 7),
            imageInfoLabel.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            imageInfoLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            // 오버레이
            overlayView.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor),
            
            // 카테고리, 좋아요
            tagStackView.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 12),
            tagStackView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 12),
            likedCountStackView.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: -12),
            likedCountStackView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 12),
            
            // 타이틀, 설명
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -4),
            descriptionLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 12),
            descriptionLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -4),
            dateLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 12),
            dateLabel.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -12)
        ])
    }
    
    // 데이터 연결 (viewModel 구현 후 지울예정)
    func configure(with place: PlaceModel) {
        catetoryLabel.text = place.category
        likedCountLabel.text = place.likedCount.description
        thumbnailImageView.image = UIImage(named: place.imageName)
        titleLabel.text = place.title
        descriptionLabel.text = place.description
        dateLabel.text = place.date
    }
}

//struct PlaceModel {
//    let category: String
//    let likedCount: Int
//    let title: String
//    let description: String
//    let imageName: String
//    let date: String
//}
