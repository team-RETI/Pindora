//
//  CustomToastView.swift
//  Pindora
//
//  Created by eunchanKim on 9/18/25.
//

import UIKit

final class CustomToastView: UILabel {
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        numberOfLines = 0
        textAlignment = .center
        font = .systemFont(ofSize: 14, weight: .medium)
        textColor = .white
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 12
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
        // 내부 패딩
        let inset: CGFloat = 12
        let insets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        // AutoLayout에서 intrinsic size에 패딩 반영
        drawText(in: bounds.inset(by: insets))
        // 패딩을 위해 contentInsets-like trick
        self.addPadding(insets)
    }
    required init?(coder: NSCoder) { fatalError() }
}

private extension UILabel {
    func addPadding(_ insets: UIEdgeInsets) {
        // UILabel에 패딩을 주는 간단 트릭: 패딩용 wrapper view를 사용
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.backgroundColor = .clear
        superview?.addSubview(wrapper)
    }
}

extension UIViewController {
    /// 하단 토스트
    func showToast(
        _ text: String,
        duration: TimeInterval = 1.8,
        bottomSpacing: CGFloat = 32
    ) {
        let toast = CustomToastView(text: text)
        view.addSubview(toast)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: safe.leadingAnchor, constant: 16),
            safe.trailingAnchor.constraint(greaterThanOrEqualTo: toast.trailingAnchor, constant: 16),
            toast.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: bottomSpacing)
        ])
        toast.alpha = 0

        UIView.animate(withDuration: 0.25) {
            toast.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: duration, options: .curveEaseInOut) {
                toast.alpha = 0
            } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }

    /// 상단 토스트
    func showTopToast(
        _ text: String,
        duration: TimeInterval = 1.6,
        topSpacing: CGFloat = 12
    ) {
        let toast = CustomToastView(text: text)
        view.addSubview(toast)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: safe.leadingAnchor, constant: 16),
            safe.trailingAnchor.constraint(greaterThanOrEqualTo: toast.trailingAnchor, constant: 16),
            toast.topAnchor.constraint(equalTo: safe.topAnchor, constant: topSpacing)
        ])
        toast.alpha = 0

        UIView.animate(withDuration: 0.25) {
            toast.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: duration, options: .curveEaseInOut) {
                toast.alpha = 0
            } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }
}

