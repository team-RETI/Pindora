//  MyPlaceViewView.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

// MARK: - (C)MyPlaceView
final class MyPlaceView: UIView {
    let placeListView = CardCellListView()
    
    // MARK: - UI Component
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "My Place"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .black
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
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
        backgroundColor = .white
        headerStack.addArrangedSubview(headerLabel)
        headerStack.addArrangedSubview(addButton)

        addSubview(headerStack)
        addSubview(placeListView)
    }

    // MARK: - (F)Constraints
    private func setupConstraints() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        placeListView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 26),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -26),

            addButton.widthAnchor.constraint(equalToConstant: 35),
            addButton.heightAnchor.constraint(equalToConstant: 35),

            placeListView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 17),
            placeListView.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeListView.trailingAnchor.constraint(equalTo: trailingAnchor),
            placeListView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

