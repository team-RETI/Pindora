//
//  ProfilePlaceCellView.swift
//  Pindora
//
//  Created by eunchanKim on 7/18/25.
//

import UIKit

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
    
//    func configure(with imageURLString: String?) {
//        guard let imageURLString,
//              let url = URL(string: imageURLString) else {
//            imageView.image = UIImage(named: "placeholder")
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
//            guard let data = data, error == nil else { return }
//            
//            DispatchQueue.main.async {
//                self?.imageView.image = UIImage(data: data)
//            }
//        }.resume()
//    }
    
    private func normalizeNaverNewsImageURL(_ urlString: String?) -> URL? {
        guard var s = urlString, !s.isEmpty else { return nil }

        // http → https
        if s.hasPrefix("http://") {
            s = "https://" + s.dropFirst(7)
        }

        guard var comp = URLComponents(string: s) else { return nil }

        // imgnews.naver.net → imgnews.pstatic.net (호스트 불일치 해결)
        if let host = comp.host, host == "imgnews.naver.net" {
            comp.host = "imgnews.pstatic.net"
        }

        return comp.url
    }
    
    func setImage(urlString: String?) {
        // 기본값: placeholder
        imageView.image = UIImage(named: "placeholder")
        // 입력 정리
        guard let url = normalizeNaverNewsImageURL(urlString) else {
            imageView.image =  UIImage(named: "placeholder")
            return
        }
        
        var req = URLRequest(url: url,
                             cachePolicy: .returnCacheDataElseLoad,
                             timeoutInterval: 15)
        // 가끔 UA 필요할 때가 있어 기본 UA 부여
        req.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile",
                     forHTTPHeaderField: "User-Agent")
        
        // 이미지 요청
        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err {
                print("❌ Image load failed:", err.localizedDescription)
                return
            }
            if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                print("❌ HTTP \(http.statusCode) for \(url)")
                return
            }
            guard let data = data, let img = UIImage(data: data) else {
                print("❌ Decode failed")
                return
            }
            DispatchQueue.main.async {
                self.imageView.image = img
            }
        }.resume()
    }
    // 목업 테스트용
//    func configure(with image: UIImage?) {
//        imageView.image = image
//    }
}
