//
//  GradientProgressCardView.swift
//  Pindora
//
//  Created by eunchanKim on 8/18/25.
//

import UIKit

final class GradientProgressCardView: UIView {

    // MARK: - Public
    private(set) var progress: CGFloat = 0   // 0...1
    var cornerRadius: CGFloat = 20 { didSet { layer.cornerRadius = cornerRadius; setNeedsLayout() } }

    // 팔레트(애플카드 느낌 톤) - 필요하면 더 추가
    private let palettes: [[UIColor]] = [
        [#colorLiteral(red: 0.99, green: 0.36, blue: 0.27, alpha: 1), #colorLiteral(red: 0.99, green: 0.59, blue: 0.19, alpha: 1), #colorLiteral(red: 0.56, green: 0.21, blue: 0.92, alpha: 1)],
        [#colorLiteral(red: 0.26, green: 0.87, blue: 0.87, alpha: 1), #colorLiteral(red: 0.13, green: 0.56, blue: 0.99, alpha: 1), #colorLiteral(red: 0.36, green: 0.18, blue: 0.93, alpha: 1)],
        [#colorLiteral(red: 0.98, green: 0.47, blue: 0.74, alpha: 1), #colorLiteral(red: 0.99, green: 0.74, blue: 0.28, alpha: 1), #colorLiteral(red: 0.99, green: 0.9, blue: 0.49, alpha: 1)],
        [#colorLiteral(red: 0.27, green: 0.95, blue: 0.54, alpha: 1), #colorLiteral(red: 1.0, green: 0.72, blue: 0.32, alpha: 1), #colorLiteral(red: 0.99, green: 0.33, blue: 0.44, alpha: 1)]
    ]

    // MARK: - Layers & UI
    private let gradientLayer = CAGradientLayer()
    private let fillMaskLayer = CALayer()         // 채움 비율을 조절하는 마스크
    private let percentLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .boldSystemFont(ofSize: 28)
        l.textColor = .white
        l.adjustsFontSizeToFitWidth = true
        return l
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); commonInit() }

    private func commonInit() {
        // 카드 기본 스타일
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 16

        // 그라데이션
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.colors = palettes[0].map { $0.cgColor }
        layer.insertSublayer(gradientLayer, at: 0)

        // 마스크(아래에서 위로 채워지는 형태)
        fillMaskLayer.backgroundColor = UIColor.white.cgColor
        gradientLayer.mask = fillMaskLayer

        // 퍼센트 라벨
        addSubview(percentLabel)
        setProgress(0, animated: false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        percentLabel.frame = bounds.insetBy(dx: 16, dy: 12)
        updateMaskFrame(animated: false)
    }

    // MARK: - Public API

    /// 0...1로 진행률 설정
    func setProgress(_ value: CGFloat, animated: Bool) {
        let p = max(0, min(1, value))
        let old = progress
        progress = p
        percentLabel.text = "\(Int(round(p * 100)))%"

        updateMaskFrame(animated: animated)

        // 살짝 팝 애니메이션(선택 시 보상감)
        if animated, p > old {
            animateBump()
        }
    }

    /// 키워드가 선택될 때 팔레트 변경(애플카드 같은 부드러운 색 전환)
    func morphToNextPalette(animated: Bool = true) {
        // 다음 팔레트 선택(랜덤 or 순환)
        let target = palettes.randomElement() ?? palettes[0]
        let toColors = target.map { $0.cgColor }

        guard animated else { gradientLayer.colors = toColors; return }

        let anim = CABasicAnimation(keyPath: "colors")
        anim.fromValue = gradientLayer.colors
        anim.toValue = toColors
        anim.duration = 0.6
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(anim, forKey: "colors")
        gradientLayer.colors = toColors
    }

    // MARK: - Private

    private func updateMaskFrame(animated: Bool) {
        let totalH = bounds.height
        let filledH = totalH * progress    // 아래에서 위로 채워짐
        let newFrame = CGRect(x: 0, y: totalH - filledH, width: bounds.width, height: filledH)

        if animated {
            let anim = CABasicAnimation(keyPath: "bounds")
            anim.fromValue = fillMaskLayer.bounds
            anim.toValue   = CGRect(origin: .zero, size: newFrame.size)
            anim.duration  = 0.35
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            let posAnim = CABasicAnimation(keyPath: "position")
            posAnim.fromValue = fillMaskLayer.position
            posAnim.toValue   = CGPoint(x: newFrame.midX, y: newFrame.midY)
            posAnim.duration  = anim.duration
            posAnim.timingFunction = anim.timingFunction

            fillMaskLayer.add(anim, forKey: "bounds")
            fillMaskLayer.add(posAnim, forKey: "position")
        }
        fillMaskLayer.frame = newFrame
    }

    private func animateBump() {
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut]) {
            self.transform = CGAffineTransform(scaleX: 1.015, y: 1.015)
        } completion: { _ in
            UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseIn]) {
                self.transform = .identity
            }
        }
    }
}
