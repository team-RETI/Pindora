//
//  FavoriteLabelView.swift
//  Pindora
//
//  Created by eunchanKim on 10/15/25.
//

import UIKit

final class FavoriteLabelView: UIView {
    
    // MARK: - UI Component
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "flag")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
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

    // MARK: - (F)UI Setup
    private func setupUI() {
        backgroundColor = .white
        clipsToBounds = true
        
        addSubview(iconImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 12),
            iconImageView.heightAnchor.constraint(equalToConstant: 12),
            
            widthAnchor.constraint(equalToConstant: 21),
            heightAnchor.constraint(equalToConstant: 21)
        ])
    }
}
