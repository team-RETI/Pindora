//  OneTimeAskViewView.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

// MARK: - (C)OneTimeAskView
final class OneTimeAskView: UIView {
    
    // MARK: - UI Component
    let nextButton = NextButton(title: "다음")

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
        backgroundColor = .white
        
        [nextButton].forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    // MARK: - (F)Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40),
            nextButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            nextButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 45),
        ])
    }
}

#Preview {
    OneTimeAskViewController(viewModel: LoginViewModel(authUseCase: StubAuthUseCaseImpl(), userUseCase: StubUserUsecaseImpl()))
}
