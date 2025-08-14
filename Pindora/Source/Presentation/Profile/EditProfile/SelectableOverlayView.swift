//
//  SelectableOverlayView.swift
//  Pindora
//
//  Created by eunchanKim on 8/3/25.
//

import UIKit

final class SelectableOverlayView: UIView {
    // MARK: - (C)ImageSelectorView
    
    var isSelected: Bool = false {
        didSet {
            toggleImage()
        }
    }

    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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

    // MARK: - (F)UI Setup
    private func setupUI() {
        addSubview(button)
    }

    // MARK: - (F)Constraints
    private func setupConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.1),
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func toggleImage() {
        let imageName = isSelected ? "checkmark.circle.fill" : "plus.circle.fill"
        let image = UIImage(systemName: imageName)
        button.setImage(image, for: .normal)
    }

    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        button.addTarget(target, action: action, for: controlEvents)
    }
}
