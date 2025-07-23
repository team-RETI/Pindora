//
//  CustomNavBarView.swift
//  Pindora
//
//  Created by eunchanKim on 7/23/25.
//

import UIKit

final class CustomNavBarView: UIView {
    
    // MARK: - UI Component
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    private let navBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // MARK: - Initializer
    init(title: String) {
         super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Optional Setter
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    // MARK: - (F)UI Setup
    private func setupUI() {
        addSubview(navBarView)
        navBarView.addSubview(backButton)
        navBarView.addSubview(titleLabel)
        
        navBarView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            navBarView.topAnchor.constraint(equalTo: topAnchor),
            navBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            navBarView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 44),
            
            backButton.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 22),
            
            titleLabel.centerXAnchor.constraint(equalTo: navBarView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
        ])
    }
}
