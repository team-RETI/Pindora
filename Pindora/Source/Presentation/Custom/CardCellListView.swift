//
//  CardCellListView.swift
//  Pindora
//
//  Created by eunchanKim on 7/16/25.
//

import UIKit

class CardCellListView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UI Component
    // 더미데이터 (ViewModel 구현후 없앨예정)
    private let dummyData: [(title: String, description: String, imageName: String)] = [
        ("카페 드롭탑", "분위기 좋은 루프탑 카페", "경복궁"),
        ("연남동 돈까스", "수요미식회에도 나온 맛집", "경복궁고화질"),
        ("책방 무대륙", "힐링하기 좋은 독립 서점", "스타필드"),
        ("서울숲 카페", "분위기 좋은 루프탑 카페", "남산타워"),
    ]

    // MARK: - Initializer
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - (F)UI Setup
    private func setupUI() {
        self.dataSource = self
        self.delegate = self
        self.separatorStyle = .none
        self.showsVerticalScrollIndicator = false
        self.register(CardCellView.self, forCellReuseIdentifier: "CardCellView")
        self.backgroundColor = .white
    }

    // MARK: - Bindings
    // ViewModel 구현후 없앨예정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardCellView", for: indexPath) as? CardCellView else {
            return UITableViewCell()
        }

        let place = dummyData[indexPath.row]
        let placeModel = PlaceModel(title: place.title, description: place.description, imageName: place.imageName)
        
        cell.configure(with: placeModel)
        return cell
    }
}
