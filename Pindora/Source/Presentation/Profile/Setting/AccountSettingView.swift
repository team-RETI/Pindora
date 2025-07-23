//
//  AccountSettingView.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//

import UIKit

final class AccountSettingView: UIView {
    let navigationBarView = CustomNavBarView(title: "계정 설정")
    let logoutButton = UIButton.settingListButtonStyle(title: "로그아웃")
    let deleteAccountButton = UIButton.settingListButtonStyle(title: "계정 삭제")
    
    private let accountImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo2"))
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let accountLabel: UILabel = {
        let label = UILabel()
        label.text = "User Name"
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "useremail@apple.com"
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let infoStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 2
        return sv
    }()
    
    private let containerStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 25
        sv.alignment = .center
        return sv
    }()
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - (F)UI Setup
    private func setUI() {
        backgroundColor = .white
        
        infoStack.addArrangedSubview(accountLabel)
        infoStack.addArrangedSubview(emailLabel)
        
        containerStack.addArrangedSubview(accountImageView)
        containerStack.addArrangedSubview(infoStack)
        
        addSubview(navigationBarView)
        addSubview(containerStack)
        addSubview(stackView)
        
        navigationBarView.translatesAutoresizingMaskIntoConstraints = false
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(logoutButton)
        stackView.addArrangedSubview(deleteAccountButton)
    }
    // MARK: - (F)Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            navigationBarView.topAnchor.constraint(equalTo: topAnchor),
            navigationBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBarView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 44),

            containerStack.topAnchor.constraint(equalTo: navigationBarView.bottomAnchor, constant: 33),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 31),
            
            accountImageView.widthAnchor.constraint(equalToConstant: 50),
            accountImageView.heightAnchor.constraint(equalToConstant: 50),
            
            stackView.topAnchor.constraint(equalTo: accountImageView.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])
    }
}
