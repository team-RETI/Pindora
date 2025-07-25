//  ___FILEBASENAME___View.swift
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import UIKit

// MARK: - (C)___FILEBASENAME___
final class ___VARIABLE_productName:identifier___View: UIView {
    
    // MARK: - UI Component

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

    }

    // MARK: - (F)Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([

        ])
    }
}

#Preview {
    ___FILEBASENAME___()
}
