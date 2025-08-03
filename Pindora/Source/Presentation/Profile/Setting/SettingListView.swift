//
//  SettingListView.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//

import UIKit

// MARK: - (C)SettingListView
final class SettingListView: UIView {
    let navigationBarView = CustomNavBarView(title: "설정")
    let accountButton = UIButton.settingListButtonStyle(title: "계정 설정", color: "black", image: "사람")
    let termsButton = UIButton.settingListButtonStyle(title: "서비스 약관", color: "black", image: "문서")
    let privacyButton = UIButton.settingListButtonStyle(title: "개인정보처리방침", color: "black", image: "자물쇠2")
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - (F)UI Setup
    private func setUI() {
        backgroundColor = .white
        addSubview(navigationBarView)
        addSubview(stackView)
        
        navigationBarView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(accountButton)
        stackView.addArrangedSubview(termsButton)
        stackView.addArrangedSubview(privacyButton)
    }
    //MARK: - (F)Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            navigationBarView.topAnchor.constraint(equalTo: topAnchor),
            navigationBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBarView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 44),
            
            stackView.topAnchor.constraint(equalTo: navigationBarView.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])
    }

}
