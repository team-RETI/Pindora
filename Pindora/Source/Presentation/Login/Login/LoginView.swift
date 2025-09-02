//  LoginViewView.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import SwiftUI

struct LoginView: View {
    /// View Properties
    @State private var intros: [Intro] = sampleIntros
    @State private var activeIntro: Intro?
    var onContinue: (() -> Void)?
    var body: some View {
        /// GeometryReader : 부모 뷰로부터 주어진 공간의 크기와 위치 정보를 읽을 수 있게 해주는 컨테이너 뷰
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            VStack(spacing: 0) {
                if let activeIntro {
                    Rectangle()
                        .fill(activeIntro.bgColor)
                        /// Circle and Text
                        .overlay {
                            Circle()
                                .fill(activeIntro.circleColor)
                                .frame(width: 30, height: 30)
                                .background(alignment: .leading, content: {
                                    Capsule()
                                        .fill(activeIntro.bgColor)
                                        .frame(width: size.width)
                                })
                                .background(alignment: .leading) {
                                    Text(activeIntro.text)
                                        .font(.system(size: 26))
                                        .foregroundStyle(activeIntro.textColor)
                                        .frame(width: textSize(activeIntro.text))
                                        .offset(x: 10)
                                        /// Moving Text based on text Offset
                                        .offset(x: activeIntro.textOffset)
                                }
                                /// Moving Circle in the Opposite Direction
                                .offset(x: -activeIntro.circleOffset)
                        }
                }
                loginButtons()
                    .padding(.bottom, safeArea.bottom)
                    .padding(.top, 10)
                    .background(.mainBlack)
            }
            .ignoresSafeArea()
        }
        .task {
            if activeIntro == nil {
                activeIntro = sampleIntros.first
                /// Delaying 0.15s and Strting Animation
                let oneSecond = UInt64(1_000_000_000)
                try? await Task.sleep(nanoseconds: oneSecond * UInt64(0.15))
                animate(0)
            }
        }
    }
    
    // MARK: - UI Component
    lazy var appleLoginButton = SocialLoginButton(loginType: .apple,
                                                  title: "Apple로 계속하기")
    /// Login Buttons
    @ViewBuilder
    func loginButtons() -> some View {
        VStack(spacing: 12) {
            Button {
                onContinue?()
            } label: {
                Label("Continue With Apple", systemImage: "applelogo")
                    .foregroundStyle(.mainBlack)
                    .fillButton(.white)
            }
        }
        .padding(15)
    }
    
    /// Animating Intros
    func animate(_ index: Int, _ loop: Bool = true) {
        if intros.indices.contains(index + 1) {
            /// Updating Text and Text Color
            activeIntro?.text = intros[index].text
            activeIntro?.textColor = intros[index].textColor
            
            /// Animating Offsets
            withAnimation(.snappy(duration: 1),completionCriteria: .removed) {
                activeIntro?.textOffset = -(textSize(intros[index].text) + 15)
                activeIntro?.circleOffset = -(textSize(intros[index].text) + 15) / 2
            } completion: {
                /// Resetting the Offset with Next Slide Color Change
                withAnimation(.snappy(duration: 0.8), completionCriteria: .logicallyComplete) {
                    activeIntro?.textOffset = 0
                    activeIntro?.circleOffset = 0
                    activeIntro?.circleColor = intros[index + 1].circleColor
                    activeIntro?.bgColor = intros[index + 1].bgColor
                } completion: {
                    /// Going to next slide
                    ///  Simply Recursion
                    animate(index + 1, loop)
                }
            }
        } else {
            /// Looping
            /// If looping Appied, Then Reset the Index to 0
            if loop {
                animate(0, loop)
            }
        }
    }
    
    /// Fetching Text Size based on Fonts
    func textSize(_ text: String) -> CGFloat {
        return NSString(string: text).size(withAttributes: [.font: UIFont.systemFont(ofSize: 26, weight: .regular)]).width
    }
    
}
/// Custom Modifier
extension View {
    @ViewBuilder
    func fillButton(_ color: Color) -> some View {
        self
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(color, in: .rect(cornerRadius: 15))
    }
}
