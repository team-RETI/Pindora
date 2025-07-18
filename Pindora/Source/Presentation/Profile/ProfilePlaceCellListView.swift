//
//  ProfilePlaceCellListView.swift
//  Pindora
//
//  Created by eunchanKim on 7/18/25.
//

import UIKit

final class ProfilePlaceCellListView: UICollectionView, UICollectionViewDelegate {
    
    // MARK: - UI Component
    private var savedPlaceImages: [UIImage] = ["경복궁","경복궁고화질","남산타워","서울역","스타필드 시청","스타필드","여의도 한강공원","경복궁","경복궁고화질","남산타워","서울역","스타필드 시청","스타필드","여의도 한강공원"].compactMap { UIImage(named: $0) }
    
    // MARK: - Initializer
    override init(frame: CGRect, collectionViewLayout layout : UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 12
        let itemSize = (UIScreen.main.bounds.width - spacing * 4) / 3
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        
        super.init(frame: frame, collectionViewLayout: layout)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - (F)UI Setup
    private func setUI() {
        self.dataSource = self
        self.delegate = self
        self.showsVerticalScrollIndicator = false
        self.register(ProfilePlaceCellView.self, forCellWithReuseIdentifier: "PlaceCell")
        self.backgroundColor = .white
        
    }
}

extension ProfilePlaceCellListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPlaceImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceCell", for: indexPath) as? ProfilePlaceCellView else {
            return UICollectionViewCell()
        }
        cell.configure(with: savedPlaceImages[indexPath.item])
        return cell
    }
}
