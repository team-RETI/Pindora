//
//  CustomToastView.swift
//  Pindora
//
//  Created by eunchanKim on 9/18/25.
//

import UIKit

final class CustomToastView: UILabel {
    var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12) {
        didSet { invalidateIntrinsicContentSize() }
    }

    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
        textAlignment = .center
        font = .systemFont(ofSize: 14, weight: .medium)
        textColor = .white
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        layer.cornerRadius = 12
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        // 패딩에 밀리지 않도록 우선순위 살짝 조정(옵션)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // ✅ 패딩을 실제 그리기와 사이즈 계산에 반영
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + contentInsets.left + contentInsets.right,
            height: size.height + contentInsets.top + contentInsets.bottom
        )
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let target = CGSize(width: size.width - contentInsets.left - contentInsets.right,
                            height: size.height - contentInsets.top - contentInsets.bottom)
        let fitted = super.sizeThatFits(target)
        return CGSize(
            width: fitted.width + contentInsets.left + contentInsets.right,
            height: fitted.height + contentInsets.top + contentInsets.bottom
        )
    }
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
        duration: TimeInterval = 1.2,
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
        duration: TimeInterval = 1.2,
        topSpacing: CGFloat = 12
    ) {
        let toast = CustomToastView(text: text)
        view.addSubview(toast)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: safe.leadingAnchor, constant: 16),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: safe.trailingAnchor, constant: -16),
            toast.topAnchor.constraint(equalTo: safe.topAnchor, constant: topSpacing)
        ])

        toast.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            toast.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: duration, options: .curveEaseInOut, animations: {
                toast.alpha = 0
            }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
}

