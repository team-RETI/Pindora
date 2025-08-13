//
//  SocialLoginButton.swift
//  Pindora
//
//  Created by 김동현 on 8/13/25.
//

import UIKit

final class SocialLoginButton: UIButton {
    enum LoginType {
        case apple
        case appleInverted // 반전 색상
        case kakao
    }
    
    init(loginType: LoginType, title: String) {
        // 오토 레이아웃을 쓴다면 관례적으로 호출
        super.init(frame: .zero)
        self.configure(loginType: loginType, title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(loginType: LoginType, title: String) {
        var config = UIButton.Configuration.filled()
        // image
        config.imagePlacement = .leading
        config.imagePadding = 20
        
        // title
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .loginTitleFont
            return outgoing
        }
        
        // background
        config.baseBackgroundColor = .black
        
        // button
        switch loginType {
        case .apple:
            config.image = UIImage(named: "Logo Apple")
            config.baseForegroundColor = .mainBlack
            config.background.strokeColor = .mainBlack
            config.background.strokeWidth = 1
        case .appleInverted:
            config.image = UIImage(named: "Logo Apple")?.withRenderingMode(.alwaysTemplate)
            config.baseForegroundColor = .white     // 로고/텍스트 색
        case .kakao:
            config.image = UIImage(named: "Logo Kakao")
            config.baseForegroundColor = .mainBlack
        }
        config.cornerStyle = .fixed
        config.background.cornerRadius = 15
        self.configuration = config
        
        // button press color
        self.configurationUpdateHandler = { button in
            var config = button.configuration
            switch loginType {
            case .apple:
                config?.baseBackgroundColor = button.isHighlighted ? .appleTapped : .apple
            case .appleInverted:
                config?.baseBackgroundColor = button.isHighlighted ? .appleBlackTapped : .appleBlack
            case .kakao:
                config?.baseBackgroundColor = button.isHighlighted ? .kakaoTapped : .kakao
            }
            button.configuration = config
        }
    }
}

#if DEBUG
import SwiftUI

#Preview("SocialLoginButton", traits: .sizeThatFitsLayout) {
    SocialLoginButton(loginType: .apple, title: "Apple로 계속하기")
        .getPreview()                 // SwiftUI 수정자 쓰고 싶을 때 래퍼 사용
        .frame(width: 350, height: 56)
        .padding(.horizontal, 10)
    
    SocialLoginButton(loginType: .appleInverted, title: "Apple로 계속하기")
        .getPreview()                 // SwiftUI 수정자 쓰고 싶을 때 래퍼 사용
        .frame(width: 350, height: 56)
        .padding(.horizontal, 10)
    
    SocialLoginButton(loginType: .kakao, title: "카카오로 계속하기")
        .getPreview()                 // SwiftUI 수정자 쓰고 싶을 때 래퍼 사용
        .frame(width: 350, height: 56)
        .padding(.horizontal, 10)
}
#endif

