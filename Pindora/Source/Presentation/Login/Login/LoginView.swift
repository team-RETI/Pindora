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
//        return NSString(string: text).size(withAttributes: [.font: UIFont.preferredFont(forTextStyle: .largeTitle)]).width
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

//// MARK: - (C)LoginView
//final class LoginView: UIView {
//    // MARK: - UI
//       private let topContainer = UIView()     // SwiftUI의 Rectangle + overlay 영역
//       private let titleLabel = UILabel()
//       private let circleView = UIView()
//       let appleButton = UIButton(type: .system) // VC에서 target-action 연결할 버튼
//
//       // MARK: - State
//       private var intros: [Intro] = []
//       private var currentIndex: Int = 0
//       private var isAnimating = false
//
//       // MARK: - Init
//       override init(frame: CGRect) {
//           super.init(frame: frame)
//           setupUI()
//           setupLayout()
//       }
//       required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//
//       // MARK: - Public
//       func configure(intros: [Intro]) {
//           self.intros = intros
//           guard let first = intros.first else { return }
//           // 초기 상태
//           topContainer.backgroundColor = first.bgColor
//           circleView.backgroundColor = first.circleColor
//           titleLabel.textColor = first.textColor
//           titleLabel.text = first.text
//           // 루프 시작
//           startLoopIfNeeded()
//       }
//
//       // MARK: - Private
//       private func setupUI() {
//           backgroundColor = .black
//
//           // topContainer (배경)
//           addSubview(topContainer)
//
//           // label
//           titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
//           titleLabel.textAlignment = .left
//           titleLabel.numberOfLines = 1
//           topContainer.addSubview(titleLabel)
//
//           // circle
//           circleView.backgroundColor = .white
//           circleView.layer.cornerRadius = 17.5 // 지름 35
//           circleView.layer.masksToBounds = true
//           topContainer.addSubview(circleView)
//
//           // 버튼
//           var config = UIButton.Configuration.filled()
//           config.title = "Continue With Apple"
//           config.image = UIImage(systemName: "apple.logo")
//           config.imagePadding = 8
//           config.baseBackgroundColor = .white
//           config.baseForegroundColor = .black
//           config.cornerStyle = .large
//           appleButton.configuration = config
//           addSubview(appleButton)
//       }
//
//       private func setupLayout() {
//           topContainer.translatesAutoresizingMaskIntoConstraints = false
//           titleLabel.translatesAutoresizingMaskIntoConstraints = false
//           circleView.translatesAutoresizingMaskIntoConstraints = false
//           appleButton.translatesAutoresizingMaskIntoConstraints = false
//
//           NSLayoutConstraint.activate([
//               // 상단 컨테이너는 전체 높이 중 버튼 영역을 제외한 나머지
//               topContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
//               topContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
//               topContainer.topAnchor.constraint(equalTo: topAnchor),
//               topContainer.bottomAnchor.constraint(equalTo: appleButton.topAnchor),
//
//               // 타이틀은 중앙 정렬(수평 중앙 근처)
//               titleLabel.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor),
//               titleLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor, constant: 6),
//
//               // 원(circle) 크기 35, 라벨 오른쪽 약간 겹치게
//               circleView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
//               circleView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -18),
//               circleView.widthAnchor.constraint(equalToConstant: 35),
//               circleView.heightAnchor.constraint(equalToConstant: 35),
//
//               // 애플 로그인 버튼
//               appleButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//               appleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
//               appleButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
//               appleButton.heightAnchor.constraint(equalToConstant: 56)
//           ])
//       }
//
//       private func startLoopIfNeeded() {
//           guard !isAnimating, intros.count >= 2 else { return }
//           isAnimating = true
//           // 약간의 딜레이 후 시작(0.15s)
//           DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
//               self?.animate(to: 0, loop: true)
//           }
//       }
//
//       private func textWidth(_ text: String) -> CGFloat {
//           let font = UIFont.preferredFont(forTextStyle: .largeTitle)
//           return (text as NSString).size(withAttributes: [.font: font]).width
//       }
//
//       /// SwiftUI의 animate(index:)와 동일한 흐름
//       private func animate(to index: Int, loop: Bool) {
//           guard intros.indices.contains(index + 1) else {
//               if loop { animate(to: 0, loop: loop) }
//               return
//           }
//
//           let current = intros[index]
//           let next = intros[index + 1]
//
//           // 1) 현재 문구/색 적용
//           titleLabel.text = current.text
//           titleLabel.textColor = current.textColor
//           // circle/bg 색은 다음 단계에서 바꿀 예정
//
//           // 2) 텍스트/서클 오프셋 계산
//           let w = textWidth(current.text) + 20
//           // 초기 위치(아이덴티티)
//           titleLabel.transform = .identity
//           circleView.transform = .identity
//
//           // 3) 1차 애니메이션: 텍스트를 왼쪽(-w), 원은 절반(-w/2)
//           let spring1 = UISpringTimingParameters(dampingRatio: 0.85, initialVelocity: .init(dx: 0.0, dy: 0.0))
//           let animator1 = UIViewPropertyAnimator(duration: 1.0, timingParameters: spring1)
//           animator1.addAnimations { [weak self] in
//               guard let self = self else { return }
//               self.titleLabel.transform = CGAffineTransform(translationX: -w, y: 0)
//               self.circleView.transform = CGAffineTransform(translationX: -w/2, y: 0)
//           }
//           animator1.addCompletion { [weak self] _ in
//               guard let self = self else { return }
//               // 4) 색 교체 + 위치 리셋 애니메이션
//               let spring2 = UISpringTimingParameters(dampingRatio: 0.92, initialVelocity: .init(dx: 0.0, dy: 0.0))
//               let animator2 = UIViewPropertyAnimator(duration: 0.8, timingParameters: spring2)
//               animator2.addAnimations {
//                   self.titleLabel.transform = .identity
//                   self.circleView.transform = .identity
//                   self.circleView.backgroundColor = next.circleColor
//                   self.topContainer.backgroundColor = next.bgColor
//               }
//               animator2.addCompletion { [weak self] _ in
//                   self?.animate(to: index + 1, loop: loop)
//               }
//               animator2.startAnimation()
//           }
//           animator1.startAnimation()
//       }
//}
