//  LoginViewView.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

// MARK: - (C)LoginView
final class LoginView: UIView {
    
    // MARK: - UI Component
    lazy var kakaoLoginButton = SocialLoginButton(loginType: .apple,
                                                  title: "Apple로 계속하기")

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
        self.backgroundColor = .mainWhite
        [kakaoLoginButton].forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    // MARK: - (F)Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Button
            kakaoLoginButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50),
            kakaoLoginButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            kakaoLoginButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

#Preview {
    LoginViewController(viewModel: LoginViewModel(authUseCase: StubAuthUseCaseImpl()))
}


