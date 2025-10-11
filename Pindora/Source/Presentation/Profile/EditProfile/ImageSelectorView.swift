//
//  ImageSelectorView.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//

import UIKit

final class ImageSelectorView: UIView {
    
    // MARK: - (C)ImageSelectorView
    let memojiOverlay = SelectableOverlayView()
    let customOverlay = SelectableOverlayView()
    let colorOverlay = SelectableOverlayView()
    
    private let memojiImageView = ImageSelectorView.makeImageView()
    private let customImageView = ImageSelectorView.makeImageView()
    private let colorImageView  = ImageSelectorView.makeImageView()
    
    private static func makeImageView() -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 18
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.25),
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor)
        ])
        return iv
    }
    
    private func makeOption(title: String, imageView: UIImageView, overlay: UIView) -> UIStackView {
        let overlayContainer = UIView()
        overlayContainer.addSubview(imageView)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlayContainer.addSubview(overlay)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: overlayContainer.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: overlayContainer.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: overlayContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: overlayContainer.trailingAnchor),
            
            overlay.topAnchor.constraint(equalTo: overlayContainer.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: overlayContainer.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: overlayContainer.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: overlayContainer.trailingAnchor),
        ])
        
        let label = UILabel()
        label.text = title
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [label, overlayContainer])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 9
        return stack
    }
    
    //    private func createOptionView(title: String, image: UIImage?) -> UIStackView {
    //        let imageView = UIImageView(image: image)
    //        imageView.contentMode = .scaleAspectFill
    //        imageView.layer.cornerRadius = 18
    //        imageView.clipsToBounds = true
    //        imageView.backgroundColor = .lightGray
    //        imageView.translatesAutoresizingMaskIntoConstraints = false
    //        NSLayoutConstraint.activate([
    //            imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.25),
    //            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
    //        ])
    //
    //        let label = UILabel()
    //        label.text = title
    //        label.textColor = .black
    //        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    //        label.textAlignment = .center
    //
    //        let stack = UIStackView(arrangedSubviews: [label, imageView])
    //        stack.axis = .vertical
    //        stack.alignment = .center
    //        stack.spacing = 9
    //        return stack
    //    }
    
    private func createOptionView(title: String, imageView: UIImageView, overlay: UIView) -> UIStackView {
        //        let imageView = UIImageView(image: image)
        //        imageView.contentMode = .scaleAspectFill
        //        imageView.layer.cornerRadius = 18
        //        imageView.clipsToBounds = true
        //        imageView.translatesAutoresizingMaskIntoConstraints = false
        //        imageView.backgroundColor = .lightGray
        //        NSLayoutConstraint.activate([
        //            imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.25),
        //            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        //        ])
        
        // ✅ 오버레이 겹치기
        //        let overlayContainer = UIView()
        //        overlayContainer.translatesAutoresizingMaskIntoConstraints = false
        //        overlay.translatesAutoresizingMaskIntoConstraints = false
        //        overlayContainer.addSubview(imageView)
        //        overlayContainer.addSubview(overlay)
        
        let overlayContainer = UIView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        overlay.translatesAutoresizingMaskIntoConstraints = false
        
        overlayContainer.addSubview(imageView)
        overlayContainer.addSubview(overlay)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: overlayContainer.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: overlayContainer.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: overlayContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: overlayContainer.trailingAnchor),
            
            overlay.topAnchor.constraint(equalTo: overlayContainer.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: overlayContainer.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: overlayContainer.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: overlayContainer.trailingAnchor),
        ])
        
        let label = UILabel()
        label.text = title
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [label, overlayContainer])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 9
        return stack
    }
    
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
        let memojiView = createOptionView(title: "Memoji", imageView: memojiImageView, overlay: memojiOverlay)
        let customView = createOptionView(title: "커스텀", imageView: customImageView, overlay: customOverlay) // ✅ 기존 프로퍼티 사용
        let colorView = createOptionView(title: "컬러", imageView: colorImageView, overlay: colorOverlay)
        
        let stack = UIStackView(arrangedSubviews: [customView, colorView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 40
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var overlayStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [memojiOverlay, customOverlay, colorOverlay])
        
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.tintColor = .white
        stack.spacing = 20
        stack.backgroundColor = .yellow
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
        addSubview(containerView)
        containerView.addSubview(horizontalStackView)
        //        containerView.addSubview(overlayStackView)
    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            horizontalStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            horizontalStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            //            overlayStackView.leadingAnchor.constraint(equalTo: horizontalStackView.leadingAnchor),
            //            overlayStackView.trailingAnchor.constraint(equalTo: horizontalStackView.trailingAnchor),
            //            overlayStackView.topAnchor.constraint(equalTo: horizontalStackView.topAnchor),
            //            overlayStackView.bottomAnchor.constraint(equalTo: horizontalStackView.bottomAnchor)
            
        ])
    }
    
    // 커스텀 get, set
    func setCustomImage(_ image: UIImage?) {
        customImageView.image = image
        
        if image != nil {
            colorImageView.image = nil
            colorOverlay.isHidden = false
        }
    }
    
    var selectedCustomImage: UIImage? { customImageView.image }
    
    // 컬러 get, set
    func setColorImage(_ image: UIImage?) {
        colorImageView.image = image
        
        if image != nil {
            customImageView.image = nil
            customOverlay.isHidden = false 
        }
    }
    var selectedColorImage: UIImage? { colorImageView.image }
    
}
