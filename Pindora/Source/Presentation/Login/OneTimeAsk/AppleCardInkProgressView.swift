//
//  AppleCardInkProgressView.swift
//  Pindora
//
//  Created by eunchanKim on 8/18/25.
import UIKit

final class AppleCardInkProgressView: UIView {

    enum InkMode {
        case fixedCenter      // 첫 탭으로 중심 고정, 이후 반경만 증감
        case accumulateUnion  // 탭마다 번진 원을 추가/제거 (누적)
    }

    // MARK: - Public
    var inkMode: InkMode = .fixedCenter
    private(set) var progress: CGFloat = 0      // 0...1
    var cornerRadius: CGFloat = 20 { didSet { layer.cornerRadius = cornerRadius; setNeedsLayout() } }

    // 중심 보정 파라미터(옵션)
    var inkClampingInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    var verticalBias: CGFloat = 0.35

    // MARK: - Layers & UI
    private let gradientLayer = CAGradientLayer()
    private let maskContainer = CALayer()            // 마스크 컨테이너: 여기에 번진 blob들을 붙임
    private let percentLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .boldSystemFont(ofSize: 28)
        l.textColor = .white
        l.adjustsFontSizeToFitWidth = true
        return l
    }()

    // fixedCenter용
    private var lockedCenter: CGPoint?
    private var fixedCenterBlob: CAGradientLayer?

    // accumulateUnion용: 추가한 blob들을 스택으로 관리 (LIFO)
    private var blobLayers: [CAGradientLayer] = []

    // MARK: - Palette
    private var currentPaletteIndex = 0
    private let palettes: [[UIColor]] = [
        [ #colorLiteral(red: 1, green: 0.36, blue: 0.33, alpha: 1), #colorLiteral(red: 1, green: 0.63, blue: 0.25, alpha: 1), #colorLiteral(red: 0.66, green: 0.31, blue: 0.99, alpha: 1) ],
        [ #colorLiteral(red: 0.1, green: 0.65, blue: 1, alpha: 1), #colorLiteral(red: 0.37, green: 0.89, blue: 0.71, alpha: 1) ],
        [ #colorLiteral(red: 1, green: 0.56, blue: 0.84, alpha: 1), #colorLiteral(red: 0.54, green: 0.64, blue: 1, alpha: 1), #colorLiteral(red: 0.3, green: 0.9, blue: 0.98, alpha: 1) ],
        [ #colorLiteral(red: 0.99, green: 0.33, blue: 0.44, alpha: 1), #colorLiteral(red: 1, green: 0.72, blue: 0.32, alpha: 1), #colorLiteral(red: 0.27, green: 0.95, blue: 0.54, alpha: 1) ]
    ]

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 16

        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        gradientLayer.colors     = palettes[0].map { $0.cgColor }
        gradientLayer.cornerRadius = cornerRadius
        layer.insertSublayer(gradientLayer, at: 0)

        // 그라데이션에 마스크 적용
        gradientLayer.mask = maskContainer

        addSubview(percentLabel)
        updatePercentLabel(0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        percentLabel.frame = bounds.insetBy(dx: 16, dy: 12)

        if inkMode == .fixedCenter, let blob = fixedCenterBlob, let c = lockedCenter {
            blob.position = c
        }
    }

    // MARK: - Public API

    /// 선택(+) 시 호출
    func applyTap(at point: CGPoint?, increment inc: CGFloat) {
        let incClamped = max(0, min(1, inc))
        let newProgress = min(1, progress + incClamped)

        switch inkMode {
        case .fixedCenter:
            if lockedCenter == nil {
                lockedCenter = CGPoint(x: bounds.midX, y: bounds.midY)
            }
            growFixedCenterBlob(toCoverage: newProgress)

        case .accumulateUnion:
            let p = point ?? CGPoint(x: bounds.midX, y: bounds.midY)
            addFeatheredBlob(at: p, toCoverage: newProgress)
        }

        morphToNextPalette()
        bump()
    }

    /// 해제(−) 시 호출
    func removeTap(decrement dec: CGFloat) {
        let decClamped = max(0, min(1, dec))
        let newProgress = max(0, progress - decClamped)

        switch inkMode {
        case .fixedCenter:
            shrinkFixedCenterBlob(toCoverage: newProgress)

        case .accumulateUnion:
            removeLastBlob(toCoverage: newProgress)
        }
    }

    // MARK: - Feathered blob helpers

    /// 번진 원(방사형 그라데이션) 생성
    private func makeFeatherBlob(center: CGPoint, radius: CGFloat) -> CAGradientLayer {
        let g = CAGradientLayer()
        g.type = .radial
        // 마스크용: 중앙 1 → 가장자리 0 (부드러운 경계)
        g.colors = [
            UIColor.white.withAlphaComponent(1).cgColor,
            UIColor.white.withAlphaComponent(1).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        g.locations = [0.0, 0.65, 1.0] as [NSNumber]
        g.startPoint = CGPoint(x: 0.5, y: 0.5)
        g.endPoint   = CGPoint(x: 1.0, y: 1.0)
        let d = radius * 2
        g.bounds = CGRect(x: 0, y: 0, width: d, height: d)
        g.position = center
        return g
    }

    /// 고정중심: 하나의 Blob을 점점 키움(+)
    private func growFixedCenterBlob(toCoverage newProgress: CGFloat) {
        progress = newProgress
        updatePercentLabel(progress)

        let c = lockedCenter ?? CGPoint(x: bounds.midX, y: bounds.midY)
        let targetR = radiusForCoverage(progress)

        if fixedCenterBlob == nil {
            let blob = makeFeatherBlob(center: c, radius: max(12, targetR * 0.2))
            blob.transform = CATransform3DMakeScale(0.01, 0.01, 1)
            maskContainer.addSublayer(blob)
            fixedCenterBlob = blob
        }

        guard let blob = fixedCenterBlob else { return }
        let pres = blob.presentation() ?? blob
        let currentScale = (pres.value(forKeyPath: "transform.scale.x") as? CGFloat) ?? 1
        let targetScale  = (targetR * 2) / max(blob.bounds.width, 1)

        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.fromValue = currentScale
        anim.toValue   = targetScale
        anim.duration  = 0.35
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        blob.add(anim, forKey: "scaleUp")
        blob.transform = CATransform3DMakeScale(targetScale, targetScale, 1)
        blob.position = c
    }

    /// 고정중심: 반지름을 줄임(−) — 0%면 제거
    private func shrinkFixedCenterBlob(toCoverage newProgress: CGFloat) {
        progress = newProgress
        updatePercentLabel(progress)

        guard let blob = fixedCenterBlob else { return }
        let targetR = radiusForCoverage(progress)
        let pres = blob.presentation() ?? blob
        let currentScale = (pres.value(forKeyPath: "transform.scale.x") as? CGFloat) ?? 1
        let targetScale  = (targetR * 2) / max(blob.bounds.width, 1)

        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.fromValue = currentScale
        anim.toValue   = targetScale
        anim.duration  = 0.28
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        blob.add(anim, forKey: "scaleDown")
        blob.transform = CATransform3DMakeScale(targetScale, targetScale, 1)

        if newProgress <= 0.0001 {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            blob.removeFromSuperlayer()
            CATransaction.commit()
            fixedCenterBlob = nil
            lockedCenter = nil
        }
    }

    /// 누적모드: 탭할 때마다 새 Blob 추가(+)
    private func addFeatheredBlob(at center: CGPoint, toCoverage newProgress: CGFloat) {
        progress = newProgress
        updatePercentLabel(progress)

        let targetR = radiusForCoverage(progress) * 1.0
        let blob = makeFeatherBlob(center: center, radius: max(12, targetR * 0.7))
        blob.transform = CATransform3DMakeScale(0.01, 0.01, 1)
        maskContainer.addSublayer(blob)

        // 스택에 보관 (해제 시 제거용)
        blobLayers.append(blob)

        let toScale = (targetR * 2) / max(blob.bounds.width, 1)
        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.fromValue = 0.01
        anim.toValue   = toScale
        anim.duration  = 0.35
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        blob.add(anim, forKey: "scaleIn")
        blob.transform = CATransform3DMakeScale(toScale, toScale, 1)
    }

    /// 누적모드: 마지막 Blob 제거(−)
    private func removeLastBlob(toCoverage newProgress: CGFloat) {
        progress = newProgress
        updatePercentLabel(progress)

        guard let layer = blobLayers.last else { return }

        // 축소 + 페이드 아웃
        let pres = layer.presentation() ?? layer
        let fromScale = (pres.value(forKeyPath: "transform.scale.x") as? CGFloat) ?? 1

        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = fromScale
        scaleAnim.toValue   = 0.01
        scaleAnim.duration  = 0.25
        scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = layer.opacity
        fade.toValue   = 0
        fade.duration  = 0.25

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak layer] in
            layer?.removeFromSuperlayer()
        }
        layer.add(scaleAnim, forKey: "scaleOut")
        layer.add(fade, forKey: "fadeOut")
        CATransaction.setDisableActions(true)
        layer.transform = CATransform3DMakeScale(0.01, 0.01, 1)
        layer.opacity = 0
        CATransaction.commit()

        _ = blobLayers.popLast()
    }

    // MARK: - Styling / Utils

    private func updatePercentLabel(_ p: CGFloat) {
        percentLabel.text = "\(Int(round(p * 100)))%"
        percentLabel.textColor = (p < 0.12) ? .label : .white
    }

    private func radiusForCoverage(_ coverage: CGFloat) -> CGFloat {
        let maxR = hypot(bounds.width, bounds.height) * 0.6
        let minR = min(bounds.width, bounds.height) * 0.12
        let t = max(0, min(1, coverage))
        let eased = 1 - pow(1 - t, 2) // easeOut
        return minR + (maxR - minR) * eased
    }

    private func morphToNextPalette() {
        currentPaletteIndex = (currentPaletteIndex + 1) % palettes.count
        let to = palettes[currentPaletteIndex].map { $0.cgColor }
        let a = CABasicAnimation(keyPath: "colors")
        a.fromValue = gradientLayer.colors
        a.toValue = to
        a.duration = 0.6
        a.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(a, forKey: "colors")
        gradientLayer.colors = to
    }

    private func bump() {
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut]) {
            self.transform = CGAffineTransform(scaleX: 1.015, y: 1.015)
        } completion: { _ in
            UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseIn]) {
                self.transform = .identity
            }
        }
    }
}
