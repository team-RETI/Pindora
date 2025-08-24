//
//  NextButton.swift
//  Pindora
//
//  Created by 김동현 on 8/16/25.
//

import UIKit

final class NextButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        self.configure(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(title: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = .mainWhite
        config.baseBackgroundColor = .mainBlack
        
        self.configuration = config
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        self.configurationUpdateHandler = { button in
            var updated = button.configuration
            updated?.baseBackgroundColor = button.isHighlighted ? .lightGray : .mainBlack
            button.configuration = updated
        }
    }
}
