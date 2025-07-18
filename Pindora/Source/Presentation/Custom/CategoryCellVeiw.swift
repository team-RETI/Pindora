//
//  CategoryCellVeiw.swift
//  Pindora
//
//  Created by eunchanKim on 7/16/25.
//

import UIKit

final class CategoryCellVeiw: UIView {
    
    // MARK: - UI Component
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        return button
    }()
    
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
        addSubview(button)
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
        button.backgroundColor = selected ? .black : .white
        button.setTitleColor(selected ? .white : .black, for: .normal)
    }
}
