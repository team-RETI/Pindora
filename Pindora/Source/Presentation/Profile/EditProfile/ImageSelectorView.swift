//
//  ImageSelectorView.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//

import UIKit

final class ImageSelectorView: UIView {
    // 개별 항목 뷰
    private func createOptionView(title: String, image: UIImage?) -> UIStackView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.25),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor) // 정사각형
        ])
        
        let label = UILabel()
        label.text = title
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [label, imageView])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 9
        return stack
    }
    
    private func createOptionView(image: UIImage?) -> UIStackView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.25),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor) // 정사각형
        ])
        
        let label = UILabel()
        label.text = "none"
        label.textColor = .clear
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [label, imageView])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 9
        return stack
    }
    
    private lazy var checkmarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .white
        imageView.backgroundColor = .black.withAlphaComponent(0.7)
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = false // 기본은 숨김
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.25),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor) // 정사각형
        ])
        
        return imageView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        return view
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let memojiView = createOptionView(title: "Memoji", image: UIImage(systemName: "memoji"))
        let customView = createOptionView(title: "커스텀", image: UIImage(systemName: "memoji"))
        let colorView = createOptionView(title: "컬러", image: UIImage(systemName: "memoji"))
        
        let stack = UIStackView(arrangedSubviews: [memojiView, customView, colorView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var overrayStackView: UIStackView = {
        let memojiView = createOptionView(image: UIImage(systemName: "checkmark.circle.fill"))
        let customView = createOptionView(image: UIImage(systemName: "checkmark.circle.fill"))
        let colorView = createOptionView(image: UIImage(systemName: "checkmark.circle.fill"))
        
        let stack = UIStackView(arrangedSubviews: [memojiView, customView, colorView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.tintColor = .white
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(horizontalStackView)
//        containerView.addSubview(checkmarkView)
        containerView.addSubview(overrayStackView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            horizontalStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            horizontalStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            overrayStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            overrayStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            
        ])
    }
}

