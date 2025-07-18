//
//  UIButton+.swift
//  Pindora
//
//  Created by eunchanKim on 7/18/25.
//

import UIKit

extension UIButton {
    static func setRoundedStyle(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .black
        button.tintColor = .white
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        return button
    }
}
