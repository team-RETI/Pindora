//  LoginViewView.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import AuthenticationServices

// MARK: - (C)LoginView
final class LoginView: UIView {
    
    // MARK: - UI Component
    let appleLoginButton = ASAuthorizationAppleIDButton()

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
        backgroundColor = .systemBackground
        appleLoginButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(appleLoginButton)
    }

    // MARK: - (F)Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            appleLoginButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            appleLoginButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100),
            appleLoginButton.widthAnchor.constraint(equalToConstant: 250),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

#Preview {
    LoginView()
}
