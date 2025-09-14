//
//  CardDetailView.swift
//  Pindora
//
//  Created by eunchanKim on 7/29/25.
//

import UIKit

final class CardDetailView: UIView {
    
    // MARK: - UI Component
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let tagLabelView = TagLabelView(title: "관광지")
    private let likeCountLabelView = LikeCountLabelView(count: 159)
    lazy var pinButton  = UIButton.detailButtonStyle(name: "pin")
    lazy var instaButton = UIButton.detailButtonStyle(name: "insta")
    lazy var flagButton  = UIButton.detailButtonStyle(name: "flag")
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.text = "경복궁"
        return label
    }()

    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "서울특별시 종로구 사직로 161"
        return label
    }()

    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()

    private let hashtagLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 0 // 자동 줄바꿈 허용
        label.text = "#경복궁 #광화문 #세종대왕 #야간관람"
        return label
    }()
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [pinButton, instaButton, flagButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "sample1")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        return imageView
    }()

    private let locationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.text = "위치정보"
        return label
    }()

    private let mapImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "map")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var headerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, UIView(), closeButton])
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
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
        backgroundColor = .black
//        addSubview(scrollView)
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(contentView)
        contentView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        1. 스크롤뷰 2. 스택뷰
        [headerStack, addressLabel, hashtagLabel, buttonStack, mainImageView,
         locationTitleLabel, mapImageView, tagLabelView, likeCountLabelView ].forEach {
//            scrollView.addSubview($0)
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    // MARK: - (F)Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            scrollView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            
            headerStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            headerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            
            addressLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 7),
            addressLabel.leadingAnchor.constraint(equalTo: headerStack.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: headerStack.trailingAnchor),
            
            hashtagLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 7),
            hashtagLabel.leadingAnchor.constraint(equalTo: headerStack.leadingAnchor),
            hashtagLabel.trailingAnchor.constraint(equalTo: headerStack.trailingAnchor),
            
            buttonStack.topAnchor.constraint(equalTo: hashtagLabel.bottomAnchor, constant: 17),
            buttonStack.leadingAnchor.constraint(equalTo: headerStack.leadingAnchor),
    
            tagLabelView.centerYAnchor.constraint(equalTo: buttonStack.centerYAnchor),
            tagLabelView.trailingAnchor.constraint(equalTo: headerStack.trailingAnchor),
            likeCountLabelView.centerYAnchor.constraint(equalTo: buttonStack.centerYAnchor),
            likeCountLabelView.trailingAnchor.constraint(equalTo: tagLabelView.leadingAnchor, constant: -9),
            
            mainImageView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 25),
            mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 76),
            mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -76),
            mainImageView.heightAnchor.constraint(equalTo: mainImageView.widthAnchor),
            
            locationTitleLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 40),
            locationTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            mapImageView.topAnchor.constraint(equalTo: locationTitleLabel.bottomAnchor, constant: 13),
            mapImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            mapImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            mapImageView.heightAnchor.constraint(equalTo: mapImageView.widthAnchor)
            
//            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
//            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            
//            headerStack.topAnchor.constraint(equalTo: contentView.topAnchor),
//            headerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
//            headerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
//            
//            addressLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 7),
//            addressLabel.leadingAnchor.constraint(equalTo: headerStack.leadingAnchor),
//            addressLabel.trailingAnchor.constraint(equalTo: headerStack.trailingAnchor),
//            
//            hashtagLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 7),
//            hashtagLabel.leadingAnchor.constraint(equalTo: headerStack.leadingAnchor),
//            hashtagLabel.trailingAnchor.constraint(equalTo: headerStack.trailingAnchor),
//            
//            buttonStack.topAnchor.constraint(equalTo: hashtagLabel.bottomAnchor, constant: 17),
//            buttonStack.leadingAnchor.constraint(equalTo: headerStack.leadingAnchor),
//    
//            tagLabelView.centerYAnchor.constraint(equalTo: buttonStack.centerYAnchor),
//            tagLabelView.trailingAnchor.constraint(equalTo: headerStack.trailingAnchor),
//            likeCountLabelView.centerYAnchor.constraint(equalTo: buttonStack.centerYAnchor),
//            likeCountLabelView.trailingAnchor.constraint(equalTo: tagLabelView.leadingAnchor, constant: -9),
//            
//            mainImageView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 25),
//            mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 76),
//            mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -76),
//            mainImageView.heightAnchor.constraint(equalTo: mainImageView.widthAnchor),
//            
//            locationTitleLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 40),
//            locationTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            
//            mapImageView.topAnchor.constraint(equalTo: locationTitleLabel.bottomAnchor, constant: 13),
//            mapImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
//            mapImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
//            mapImageView.heightAnchor.constraint(equalTo: mapImageView.widthAnchor)
            ])
    }
}
