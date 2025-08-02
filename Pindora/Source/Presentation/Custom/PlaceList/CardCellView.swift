//
//  CardCellView.swift
//  Pindora
//
//  Created by eunchanKim on 7/16/25.
//

import UIKit

final class CardCellView: UITableViewCell {
    
    // MARK: - UI Component
    private let tagLabelView = TagLabelView()
    private let likeCountLabelView = LikeCountLabelView()
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let thumbnailContainerView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.masksToBounds = false
        return view
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
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
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        selectionStyle = .none
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - (F)UI Setup
    private func setupUI() {
        contentView.addSubview(thumbnailContainerView)
        thumbnailContainerView.addSubview(thumbnailImageView)
        thumbnailImageView.addSubview(overlayView)
        thumbnailImageView.addSubview(titleLabel)
        thumbnailImageView.addSubview(descriptionLabel)
        thumbnailImageView.addSubview(dateLabel)
        thumbnailImageView.addSubview(tagLabelView)
        thumbnailImageView.addSubview(likeCountLabelView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
        tagLabelView.layer.cornerRadius = tagLabelView.frame.height / 2
        likeCountLabelView.layer.cornerRadius = likeCountLabelView.frame.height / 2
    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {

        thumbnailContainerView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabelView.translatesAutoresizingMaskIntoConstraints = false
        likeCountLabelView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thumbnailContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 26),
            thumbnailContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -26),
            thumbnailContainerView.topAnchor.constraint(equalTo: topAnchor),
            thumbnailContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            // 이미지 뷰
            thumbnailImageView.leadingAnchor.constraint(equalTo: thumbnailContainerView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: thumbnailContainerView.trailingAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: thumbnailContainerView.topAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: thumbnailContainerView.bottomAnchor),
            
            // 오버레이
            overlayView.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor),
            
            // 카테고리, 좋아요
            tagLabelView.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 12),
            tagLabelView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 12),
            likeCountLabelView.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: -12),
            likeCountLabelView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 12),
            
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
        tagLabelView.title = place.category
        likeCountLabelView.count = place.likeCount.description
        thumbnailImageView.image = UIImage(named: place.imageName)
        titleLabel.text = place.title
        descriptionLabel.text = place.description
        dateLabel.text = place.date
    }
}

struct PlaceModel {
    let category: String
    let likeCount: Int
    let title: String
    let description: String
    let imageName: String
    let date: String
}
