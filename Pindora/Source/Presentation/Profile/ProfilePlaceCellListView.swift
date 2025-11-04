//
//  ProfilePlaceCellListView.swift
//  Pindora
//
//  Created by eunchanKim on 7/18/25.
//

import UIKit

final class ProfilePlaceCellListView: UICollectionView, UICollectionViewDelegate {
    
    // MARK: - UI Component
    private var placesLog: [Place] = []
    var onPlaceSelected: ((Place) -> Void)?

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
        return min(placesLog.count, 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceCell", for: indexPath) as? ProfilePlaceCellView else {
            return UICollectionViewCell()
        }
        
        let place = placesLog[indexPath.item]
        cell.setImage(urlString: place.imageURL, category: place.category)
        return cell
    }
}

// MARK: - 추가 메서드
extension ProfilePlaceCellListView {
    func updatePlaceLog(_ places: [Place]) {
        self.placesLog = places
        self.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedPlace = placesLog[indexPath.item]
        onPlaceSelected?(selectedPlace)
    }
}
