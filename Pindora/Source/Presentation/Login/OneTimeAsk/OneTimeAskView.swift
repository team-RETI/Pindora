//  OneTimeAskViewView.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

// MARK: - (C)OneTimeAskView
final class OneTimeAskView: UIView {
    
    // 잉크 앵커들: TL → TR → BL → BR → C
    private var inkAnchors: [CGPoint] = []
    private var inkAnchorIndex = 0
    private var lastCardSize: CGSize = .zero
    
    // 외부 콜백
    var onKeywordTapped: ((UIButton, Bool) -> Void)?
    
    // MARK: - UI Component
    private let barView = CustomNavBarView(title: "어떤 장소를 추천해드릴까요?", hideBackButton: true)
    private let titleLabel = UILabel.makeTitleLabel(text: "키워드를 선택해주세요")
    private lazy var titleInfoStackView: UIStackView = {
        let image = UIImageView(image: UIImage(named: "infoImage"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 15),
            image.heightAnchor.constraint(equalToConstant: 15),
        ])
        
        let label = UILabel.makeSubInfoLabel(text: "최소 5개 이상의 키워드를 선택해야합니다")
        let stackView = UIStackView(arrangedSubviews: [image, label])
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()
    
    // test
    let cloud = KeywordCloudView(
        keywords: ["도서관","카페","관광지","식당","숙소","영화관","전시","공원","바다","산책","야시장","시장","미술관","한옥","온천","서점","드라이브","캠핑"]
    )
    // test
    let card = AppleCardInkProgressView()
    private var progress: CGFloat = 0
    
    private lazy var previewStackView: UIStackView = {
        let image = UIImageView(image: UIImage(named: "preview"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 30),
            image.heightAnchor.constraint(equalToConstant: 30),
        ])
        let previewLabel = UILabel.makeTitleLabel(text: "내 취향 완성도")
        let stackView = UIStackView(arrangedSubviews: [image, previewLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 14
        return stackView
    }()
    
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인 및 등록", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 18
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        bindCloud()
        card.inkMode = .accumulateUnion
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 카드 사이즈가 바뀌면 앵커 재계산
    override func layoutSubviews() {
        super.layoutSubviews()
        if card.bounds.size != lastCardSize {
            lastCardSize = card.bounds.size
            recomputeInkAnchors()
        }
    }
    
    private func recomputeInkAnchors() {
        // 가장자리 너무 붙지 않게 살짝 여유(디자인에 맞게 조절)
        let inset: CGFloat = 24
        let r = card.bounds.insetBy(dx: inset, dy: inset)
        let tl = CGPoint(x: r.minX, y: r.minY)
        let tr = CGPoint(x: r.maxX, y: r.minY)
        let bl = CGPoint(x: r.minX, y: r.maxY)
        let br = CGPoint(x: r.maxX, y: r.maxY)
        let c  = CGPoint(x: r.midX, y: r.midY)
        inkAnchors = [tl, tr, bl, br, c]
        inkAnchorIndex = 0
    }
    
    // MARK: - Binding
    private func bindCloud() {
        for categoryView in cloud.rows {
            categoryView.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        }
        
        onKeywordTapped = { [weak self] button, isSelected in
            guard let self = self else { return }
            
            self.layoutIfNeeded()
            self.card.layoutIfNeeded()
            
            // 앵커가 아직 없으면 계산
            if self.inkAnchors.isEmpty { self.recomputeInkAnchors() }
            
            if isSelected {
                // ✅ 선택 시 증가
                let anchor = self.inkAnchors[self.inkAnchorIndex]
                self.inkAnchorIndex = (self.inkAnchorIndex + 1) % self.inkAnchors.count
                
                let step = CGFloat(Int.random(in: 20...25)) / 100.0
                self.progress = min(1.0, self.progress + step)
                
                // 누적 잉크: 선택한 앵커에서 원 추가
                self.card.applyTap(at: anchor, increment: step)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                
                if self.progress >= 1.0 {
                    self.registerButton.isEnabled = true
                    self.registerButton.alpha = 1
                }
                
            } else {
                // ❌ 해제 시 감소
                let step = CGFloat(Int.random(in: 20...25)) / 100.0
                self.progress = max(0.0, self.progress - step)
                
                // 👉 카드에서 "잉크 제거" 로직 필요 시 구현
                self.card.removeTap(decrement: step)
                
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                
                if self.progress < 1.0 {
                    self.registerButton.isEnabled = false
                    self.registerButton.alpha = 0.5
                }
            }
        }
    }
    
    // MARK: - (F)UI Setup
    private func setupUI() {
        backgroundColor = .white
        addSubview(barView)
        addSubview(titleLabel)
        addSubview(titleInfoStackView)
        addSubview(cloud)
        addSubview(previewStackView)
        addSubview(card)
        addSubview(registerButton)
    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        barView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        cloud.translatesAutoresizingMaskIntoConstraints = false
        previewStackView.translatesAutoresizingMaskIntoConstraints = false
        card.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            barView.topAnchor.constraint(equalTo: topAnchor),
            barView.leadingAnchor.constraint(equalTo: leadingAnchor),
            barView.trailingAnchor.constraint(equalTo: trailingAnchor),
            barView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 44),
            
            titleLabel.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleInfoStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleInfoStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            cloud.topAnchor.constraint(equalTo: titleInfoStackView.bottomAnchor, constant: 10),
            cloud.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            cloud.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cloud.heightAnchor.constraint(equalToConstant: 190),
            
            previewStackView.topAnchor.constraint(equalTo: cloud.bottomAnchor, constant: 20),
            previewStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            previewStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            previewStackView.heightAnchor.constraint(equalToConstant: 75),
            
            // 카드
            card.topAnchor.constraint(equalTo: previewStackView.bottomAnchor, constant: 20),
            card.leadingAnchor.constraint(equalTo: cloud.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: cloud.trailingAnchor),
            card.heightAnchor.constraint(equalToConstant: 190),
            
            registerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            registerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            registerButton.heightAnchor.constraint(equalToConstant: 50),
            registerButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35)
        ])
    }
    
    @objc private func categoryTapped(_ sender: UIButton) {
        guard let cellView = sender.superview as? CategoryCellView else {
            print("❌ CategoryCellView로 캐스팅 실패 - sender.superview: \(String(describing: sender.superview))")
            return
        }
        
        let now = !sender.isSelected
        sender.isSelected = now
        UIView.animate(withDuration: 0.15) {
            if now {
                sender.backgroundColor = .black
                sender.setTitleColor(.white, for: .normal)
                sender.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
            } else {
                sender.backgroundColor = .gray1
                sender.setTitleColor(.gray3, for: .normal)
                sender.transform = .identity
            }
        }
        
        let selectedTitle = cellView.titleText
        print("✅ 선택된 카테고리: \(selectedTitle ?? "-")")
        
        onKeywordTapped?(sender, now)
    }
}
