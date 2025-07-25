//
//  UILabel+.swift
//  Pindora
//
//  Created by eunchanKim on 7/25/25.
//

import UIKit

extension UILabel {
    static func makeTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }
    
    static func makeSubInfoLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }
}
