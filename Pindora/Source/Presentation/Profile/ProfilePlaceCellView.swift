//
//  ProfilePlaceCellView.swift
//  Pindora
//
//  Created by eunchanKim on 7/18/25.
//

import UIKit
import Kingfisher

final class ProfilePlaceCellView: UICollectionViewCell {
    
    // MARK: - UI Component
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.masksToBounds = false
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - (F)UI Setup
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    private func normalizeNaverNewsImageURL(_ urlString: String?) -> URL? {
        guard var s = urlString, !s.isEmpty else { return nil }
        if s.hasPrefix("http://") { s = "https://" + s.dropFirst(7) }
        guard var comp = URLComponents(string: s) else { return nil }
        if comp.host == "imgnews.naver.net" { comp.host = "imgnews.pstatic.net" }
        return comp.url
    }
        
    /// 이미지 연결
    /// - Parameters:
    ///   - urlString: 이미지 URL 혹은 nil
    ///   - category: 이미지 실패 시 카테코리를 이용한 이미지 매칭
    func setImage(urlString: String?, category: String) {
        // 카테고리 기반 플레이스홀더
        let fallbackName = KakaoCategoryGroup.from(displayName: category)?.rawValue ?? "placeholder"
        let placeholder = UIImage(named: fallbackName) ?? UIImage(named: "placeholder")
        
        // URL 정리
        guard let url = normalizeNaverNewsImageURL(urlString) else {
            imageView.image = placeholder
            return
        }
        
        // 다운샘플링 + 둥근 모서리 등 필요한 프로세서 구성 (둥근 모서리 필요 없으면 제거)
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
        
        // UA 헤더가 필요한 경우에만 붙일 수 있도록 AnyModifier 사용
        let uaModifier = AnyModifier { request in
            var r = request
            r.setValue(
                "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile",
                forHTTPHeaderField: "User-Agent"
            )
            return r
        }
        
        let options: KingfisherOptionsInfo = [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(0.15)),
            .backgroundDecode,
            .keepCurrentImageWhileLoading,
            .cacheOriginalImage,
            .onFailureImage(placeholder),      // 실패 시 카테고리 이미지로
            .requestModifier(uaModifier)       // UA 필요 시
        ]
        
        // 필요 시: 디스크/메모리 캐시 전략 조정도 가능
        // options.append(.memoryCacheExpiration(.days(1)))
        // options.append(.diskCacheExpiration(.days(7)))
        
        imageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: options
        ) { result in
            if case let .failure(error) = result {
                print("❌ Kingfisher load failed:", error)
            }
        }
    }
}
