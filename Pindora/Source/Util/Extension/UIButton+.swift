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
    
    static func settingListButtonStyle(title: String, color: String, image: String) -> UIButton {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: image)
        config.imagePlacement = .leading
        config.imagePadding = 16

        
        let font = UIFont.systemFont(ofSize: 17, weight: .medium)
        let attributed = NSAttributedString(
            string: title,
            attributes: [.font: font]
        )
        
        config.attributedTitle = AttributedString(attributed)
        
        button.contentHorizontalAlignment = .leading
        button.layer.cornerRadius = 12
        button.backgroundColor = .white
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.configuration = config
        
        switch color.lowercased() {
        case "red":
            button.tintColor = .red
        case "black":
            button.tintColor = .black
        default: break
        }
        return button
    }
    
    static func detailButtonStyle(name: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: name), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return button
    }
}
