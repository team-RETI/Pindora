//
//  FontSystem.swift
//  Pindora
//
//  Created by eunchanKim on 7/10/25.
//

import UIKit

extension UIFont {
    enum Pretendard: String {
        case black = "Pretendard-Black"
        case bold = "Pretendard-Bold"
        case extraBold = "Pretendard-ExtraBold"
        case extraLight = "Pretendard-ExtraLight"
        case light = "Pretendard-Light"
        case medium = "Pretendard-Medium"
        case regular = "Pretendard-Regular"
        case semiBold = "Pretendard-SemiBold"
        case thin = "Pretendard-Thin"
    }
}

extension UIFont {
    
    /// Pretendard 커스텀 폰트륿 반환합니다.
    /// - Parameters:
    ///   - weight: Pretendard enum
    ///   - size: 폰트 크기
    /// - Returns: UIFont 인스턴스
    static func customFont(_ weight: Pretendard, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

// Pindora 프리셋 폰트
extension UIFont {
    
    static var logoFont: UIFont {
        customFont(.bold, size: 24)
    }
    
    static var titleFont: UIFont {
        customFont(.bold, size: 20)
    }

    static var bodyFont: UIFont {
        customFont(.regular, size: 15)
    }

    static var captionFont: UIFont {
        customFont(.medium, size: 12)
    }
}

// FontView는 폰트 스타일을 테스트하기 위한 디버깅용 뷰입니다.
// 앱 출시 시 포함되지 않도록 DEBUG 빌드에서만 컴파일되도록 설정합니다.
#if DEBUG
final class FontView: UIView {
    
    // MARK: - UI Component
    private lazy var logoLabel: UILabel = {
        let label = UILabel()
        label.font = .logoFont
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "logo size 24"
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .titleFont
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "title size 20"
        return label
    }()
    
    private lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyFont
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "body size 15"
        return label
    }()
    
    private lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.font = .captionFont
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "caption size 12"
        return label
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [logoLabel, titleLabel, bodyLabel, captionLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        addSubview(hStackView)
        hStackView.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            hStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

#Preview {
    FontView()
}
#endif

