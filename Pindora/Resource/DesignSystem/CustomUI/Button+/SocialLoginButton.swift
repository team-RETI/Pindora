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
        case kakao
    }
    
    init(loginType: LoginType, title: String) {
        // 오토 레이아웃을 쓴다면 관례적으로 호출
        super.init(frame: .zero)
        self.backgroundColor = .systemBlue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(loginType: LoginType, title: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        self.configuration = config
    }
}

#if DEBUG
import SwiftUI

// ✅ 하나만 쓰기 (#Preview 추천)
#Preview("SocialLoginButton", traits: .sizeThatFitsLayout) {
    SocialLoginButton(loginType: .apple, title: "애플로 로그인")
        .getPreview()                 // SwiftUI 수정자 쓰고 싶을 때 래퍼 사용
        .frame(width: 200, height: 56)
        .padding()
}
#endif

