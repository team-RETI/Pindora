//
//  GalleryCollectionView.swift
//  Pindora
//
//  Created by eunchanKim on 10/25/25.
//
import UIKit
import Combine

final class GalleryCollectionView: UIView {
    private var cancellables = Set<AnyCancellable>()
    private var images: [UIImage] = []

    // ✅ 수평 스크롤 레이아웃
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 330, height: 300)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupView() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: GalleryCell.id)
        collectionView.dataSource = self
    }

    // ✅ Combine 바인딩
    func bind(to publisher: AnyPublisher<[UIImage?], Never>) {
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imgs in
                guard let self else { return }
                self.images = imgs.compactMap { $0 } // nil 제거
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension GalleryCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCell.id, for: indexPath) as! GalleryCell
        cell.configure(image: images[indexPath.item])
        return cell
    }
}

// ✅ 셀 정의
final class GalleryCell: UICollectionViewCell {
    static let id = "GalleryCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 14
        iv.clipsToBounds = true
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(image: UIImage) {
        imageView.image = image
    }
}
