//
//  CategoryCellView.swift
//  Pindora
//
//  Created by eunchanKim on 7/16/25.
//

import UIKit

final class CategoryCellView: UIView {
    
    // MARK: - UI Component
    private var button: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.clipsToBounds = true
        return button
    }()
    
    var titleText: String? {
        guard let title = button.title(for: .normal) else {
            print("❗️button에 title이 없음")
            return nil
        }
        return title
    }
    
    // MARK: - Initializer
    init(title: String) {
        super.init(frame: .zero)
        button.setTitle(title, for: .normal)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - (F)UI Setup
    private func setupUI() {
        setupShadow()
        addSubview(button)
        clipsToBounds = false 
    }
    
    private func setupConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }

    // ✅ 고정된 크기
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 70, height: 30)
    }
    
    //CornerRadius 적용
    override func layoutSubviews() {
        super.layoutSubviews()
        button.layer.cornerRadius = bounds.height / 2
    }
    
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        button.addTarget(target, action: action, for: controlEvents)
    }

    func setSelected(_ selected: Bool) {
        button.backgroundColor = selected ? .gray : .white
        button.setTitleColor(selected ? .white : .black, for: .normal)
    }
}
