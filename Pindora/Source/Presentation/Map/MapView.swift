//  MapViewView.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

// MARK: - (C)MapView
final class MapView: UIView {
    
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
    MapView()
}
