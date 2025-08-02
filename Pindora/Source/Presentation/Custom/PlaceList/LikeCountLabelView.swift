//
//  LikeCountLabelView.swift
//  Pindora
//
//  Created by eunchanKim on 8/2/25.
//

import UIKit

final class LikeCountLabelView: UIView {
    
    var count: String? {
        get { countLabel.text }
        set { countLabel.text = newValue }
    }
    
    // MARK: - UI Component
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "좋아요")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(count: Int) {
        self.init(frame: .zero)
        self.count = count.description
    }

    // MARK: - (F)UI Setup
    private func setupUI() {
        backgroundColor = .white
        clipsToBounds = true
        
        addSubview(iconImageView)
        addSubview(countLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 12),
            iconImageView.heightAnchor.constraint(equalToConstant: 12),
            
            countLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 2),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalToConstant: 21)
        ])
    }
}
