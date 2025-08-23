//
//  IntroModel.swift
//  Pindora
//
//  Created by eunchanKim on 8/23/25.
//

import SwiftUI

struct Intro: Identifiable {
    var id: UUID = .init()
    var text: String
    var textColor: Color
    var circleColor: Color
    var bgColor: Color
    var circleOffset: CGFloat = 0
    var textOffset: CGFloat = 0
}

/* 보시다시피, 텍스트와 원(circle)의 색상은 이전 배경색에서 가져옵니다
(물론 변경할 수 있지만, 텍스트 색상이 배경색 위에서 더 잘 보이도록 설정하는 게 좋습니다).

루프처럼 보이게 만들기 위해, 첫 번째 요소를 끝에 복사해 두고 마지막 요소에 도달하면 그것을 단순히 첫 번째 요소로 교체합니다.
이렇게 하면 루프 애니메이션이 만들어집니다.
 */

var sampleIntros: [Intro] = [
    .init(
        text: "안녕하세요",
        textColor: .gray0,
        circleColor: .gray0,
        bgColor: .mainBlack,
    ),
    .init(
        text: "나만의 장소를 모아보세요",
        textColor: .gray0,
        circleColor: .gray0,
        bgColor: .mainBlack,
    ),
    .init(
        text: "특별한 장소를 추천해드립니다",
        textColor: .gray0,
        circleColor: .gray0,
        bgColor: .mainBlack,
    ),
    .init(
        text: "멋진곳을 탐험해보세요",
        textColor: .gray0,
        circleColor: .gray0,
        bgColor: .mainBlack,
    ),
    .init(
        text: "나만의 페르소나를 만들어보세요",
        textColor: .gray0,
        circleColor: .gray0,
        bgColor: .mainBlack,
    ),
    .init(
        text: "나만의 페르소나를 만들어보세요",
        textColor: .gray0,
        circleColor: .gray0,
        bgColor: .mainBlack,
    )    
]

//import UIKit
//
//struct Intro {
//    var text: String
//    var textColor: UIColor
//    var circleColor: UIColor
//    var bgColor: UIColor
//    var circleOffset: CGFloat = 0
//    var textOffset: CGFloat = 0
//}
//
//let sampleIntros: [Intro] = [
//    .init(text: "Let's Create",    textColor: .white, circleColor: .white, bgColor: .black),
//    .init(text: "Let's Brain",     textColor: .white, circleColor: .white, bgColor: .black),
//    .init(text: "Let's Explore",   textColor: .white, circleColor: .white, bgColor: .black),
//    .init(text: "Let's Invent",    textColor: .white, circleColor: .white, bgColor: .black),
//    .init(text: "Let's Create",    textColor: .white, circleColor: .white, bgColor: .black)
//]
