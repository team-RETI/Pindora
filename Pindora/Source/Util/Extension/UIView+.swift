//
//  UIView+.swift
//  Pindora
//
//  Created by eunchanKim on 7/18/25.
//

import UIKit

extension UIView {
    static func makeStatView(title: String, count: Int) -> UIView {
        let countLabel = UILabel()
        countLabel.text = "\(count)"
        countLabel.font = .systemFont(ofSize: 13)
        countLabel.textAlignment = .center
        countLabel.textColor = .black

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 13)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black

        let stack = UIStackView(arrangedSubviews: [countLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4

        let container = UIView()
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }
    
}
