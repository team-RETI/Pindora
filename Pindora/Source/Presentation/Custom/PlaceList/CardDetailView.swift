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
    lazy var pinButton  = UIButton.detailButtonStyle(name: "pin")
    lazy var webButton = UIButton.detailButtonStyle(name: "internet")
    lazy var flagButton  = UIButton.detailButtonStyle(name: "flag")
    lazy var reviewLabelButton = UIButton.reviewButtonStyle()
    let tagLabelView = TagLabelView(title: "관광지")
    let galleryView = GalleryCollectionView()
    
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
    
    lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [pinButton, webButton, flagButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var reviewStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [reviewLabelButton, addButton])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let reviewTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.text = "나의 장소 리뷰"
        return label
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    let toMapViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("장소 위치 보기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        return button
    }()

    private lazy var headerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel])
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
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        [headerStack, addressLabel, buttonStack, reviewStack, galleryView,
         reviewTitleLabel, toMapViewButton, tagLabelView ].forEach {
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
            
            buttonStack.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 17),
            buttonStack.leadingAnchor.constraint(equalTo: headerStack.leadingAnchor),
    
            tagLabelView.centerYAnchor.constraint(equalTo: buttonStack.centerYAnchor),
            tagLabelView.trailingAnchor.constraint(equalTo: headerStack.trailingAnchor),
            
            galleryView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 25),
            galleryView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            galleryView.widthAnchor.constraint(equalToConstant: 330),
            galleryView.heightAnchor.constraint(equalToConstant: 300),
            
            reviewTitleLabel.topAnchor.constraint(equalTo: galleryView.bottomAnchor, constant: 40),
            reviewTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            reviewStack.topAnchor.constraint(equalTo: reviewTitleLabel.bottomAnchor, constant: 14),
            reviewStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            addButton.widthAnchor.constraint(equalToConstant: 30),
            addButton.heightAnchor.constraint(equalToConstant: 30),
            
            toMapViewButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            toMapViewButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            toMapViewButton.heightAnchor.constraint(equalToConstant: 50),
            toMapViewButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35)
            ])
    }
}
