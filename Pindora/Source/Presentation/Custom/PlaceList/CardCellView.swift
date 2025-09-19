//
//  CardCellView.swift
//  Pindora
//
//  Created by eunchanKim on 7/16/25.
//

import UIKit

final class CardCellView: UITableViewCell {
    private var task: URLSessionDataTask?
    
    // MARK: - UI Component
    private let tagLabelView = TagLabelView()
    private let likeCountLabelView = LikeCountLabelView()
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let thumbnailContainerView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.masksToBounds = false
        return view
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        selectionStyle = .none
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - (F)UI Setup
    private func setupUI() {
        contentView.addSubview(thumbnailContainerView)
        thumbnailContainerView.addSubview(thumbnailImageView)
        thumbnailImageView.addSubview(overlayView)
        thumbnailImageView.addSubview(titleLabel)
        thumbnailImageView.addSubview(descriptionLabel)
        thumbnailImageView.addSubview(dateLabel)
        thumbnailImageView.addSubview(tagLabelView)
        thumbnailImageView.addSubview(likeCountLabelView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
        tagLabelView.layer.cornerRadius = tagLabelView.frame.height / 2
        likeCountLabelView.layer.cornerRadius = likeCountLabelView.frame.height / 2
    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        
        thumbnailContainerView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabelView.translatesAutoresizingMaskIntoConstraints = false
        likeCountLabelView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thumbnailContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 26),
            thumbnailContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -26),
            thumbnailContainerView.topAnchor.constraint(equalTo: topAnchor),
            thumbnailContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            // 이미지 뷰
            thumbnailImageView.leadingAnchor.constraint(equalTo: thumbnailContainerView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: thumbnailContainerView.trailingAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: thumbnailContainerView.topAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: thumbnailContainerView.bottomAnchor),
            
            // 오버레이
            overlayView.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor),
            
            // 카테고리, 좋아요
            tagLabelView.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 12),
            tagLabelView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 12),
            likeCountLabelView.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: -12),
            likeCountLabelView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 12),
            
            // 타이틀, 설명
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -4),
            descriptionLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 12),
            descriptionLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -4),
            dateLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 12),
            dateLabel.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -12)
        ])
    }
    
    // 데이터 연결 (viewModel 구현 후 지울예정)
    func configure(with place: Place) {
        tagLabelView.title = place.category
        likeCountLabelView.count = place.likedCount?.description
        titleLabel.text = place.placeName
        descriptionLabel.text = place.placeAddress
        dateLabel.text = place.addedDate.toString()
    }
    
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
    
    /// 이미지 연결
    /// - Parameters:
    ///   - urlString: 이미지 URL 혹은 nil
    ///   - category: 이미지 실패 시 카테코리를 이용한 이미지 매칭
    func setImage(urlString: String?, category: String) {
        // 기본값: placeholder
        thumbnailImageView.image = UIImage(named: "placeholder")
        // 입력 정리
        guard let url = normalizeNaverNewsImageURL(urlString) else {
            let category = KakaoCategoryGroup.from(displayName: category)?.rawValue ?? "placeholder"
            thumbnailImageView.image = UIImage(named: category)
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
                self.thumbnailImageView.image = img
            }
        }.resume()
    }
}
