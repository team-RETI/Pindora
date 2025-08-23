//  KeywordCloudView.swift
//  Pindora
//
//  Created by eunchanKim on 8/18/25.
//
import UIKit

final class KeywordCloudView: UIView {
    // MARK: - Tunables
    private let corner: CGFloat = 18
    private let contentPadding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    private let hSpacing: CGFloat = 12
    private let vSpacing: CGFloat = 12
    private let rowCount: Int = 4
    
    // test
//    let keywordList = CategoryCellListView()
//    lazy var categoryViews: [CategoryCellView] = {
//        return keywords.map { CategoryCellView(title: $0) }
//    }()

    // MARK: - UI (4줄 컨테이너)
    private let containerView: UIView = UIView()
    var rows: [CategoryCellView] = []

    // MARK: - Data
    private let keywords: [String]
    private var allButtons: [UIButton] = []
    
    // ✅ 추가: 초기 오프셋(퍼센트/픽셀) 및 적용 여부
    var initialOffsetPercent: CGFloat = 0      // 0.0~1.0 (맨 왼쪽~맨 오른쪽)
    var initialOffsetX: CGFloat? = nil         // 픽셀로 지정하고 싶으면 이 값 우선
    private var didApplyInitialOffset = false  // 한 번만 적용하기 위한 플래그
    
    lazy var categoryStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 7
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layer.masksToBounds = true
        stack.isLayoutMarginsRelativeArrangement = true
        let offset = [0,32,0,32]
        for i in 0..<rowCount {
            let keywordListView = CategoryCellListView(frame: .zero, color: .gray1) // 👈 새로운 인스턴스 생성
            stack.addArrangedSubview(keywordListView)
            rows.append(contentsOf: keywordListView.categoryViews)
            
            DispatchQueue.main.async { [weak keywordListView] in
                guard let keywordListView else { return }
                keywordListView.setContentOffset(CGPoint(x: offset[i], y: 0), animated: false)
            }
        }
        return stack
    }()
    
    // 외부 콜백
    var onKeywordTapped: ((UIButton, Bool) -> Void)?

    // MARK: - Init
    init(keywords: [String]) {
        self.keywords = keywords
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        self.keywords = []
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        containerView.layer.cornerRadius = corner
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.clipsToBounds = true
        containerView.addSubview(categoryStack)
        
        NSLayoutConstraint.activate([
            categoryStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//            categoryStack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
            categoryStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            categoryStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
//            categoryStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14)
            
            
        ])
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
    }


    // MARK: - Action
    @objc private func tagTapped(_ sender: UIButton) {
        let now = !sender.isSelected
        sender.isSelected = now

        UIView.animate(withDuration: 0.15) {
            if now {
                sender.backgroundColor = .black
                sender.setTitleColor(.white, for: .normal)
                sender.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
            } else {
                sender.backgroundColor = UIColor(white: 0.88, alpha: 1)
                sender.setTitleColor(.label, for: .normal)
                sender.transform = .identity
            }
        }

        onKeywordTapped?(sender, now)
    }
}
