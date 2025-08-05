//  MyPlaceViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

final class MyPlaceViewController: UIViewController {
    weak var coordinator: MyPlaceCoordinator?
    private let viewModel: MyPlaceViewModel
    private let customView = MyPlaceView()
    
    private lazy var placeListView = customView.placeListView
    private let dummyData: [(title: String, description: String, imageName: String)] = [
        ("카페 드롭탑", "분위기 좋은 루프탑 카페", "경복궁"),
        ("연남동 돈까스", "수요미식회에도 나온 맛집", "경복궁고화질"),
        ("책방 무대륙", "힐링하기 좋은 독립 서점", "스타필드"),
        ("서울숲 카페", "분위기 좋은 루프탑 카페", "남산타워"),
    ]

    // MARK: - Initializer
    init(viewModel: MyPlaceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func loadView() {
        self.view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customView.addButton.addTarget(self, action: #selector(addPlaceButtonTapped), for: .touchUpInside)
        placeListView.dataSource = self
        placeListView.delegate = self
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("MyPlaceViewController")
    }

    // MARK: - Bindings
    private func bindViewModel() {

    }
    
    @objc private func addPlaceButtonTapped() {
        print("addPlaceButtonTapped")
            coordinator?.didTapAddPlace()
    }
}

extension MyPlaceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardCellView", for: indexPath) as? CardCellView else {
            return UITableViewCell()
        }
        
        //let place = dummyData[indexPath.row]
        let placeTuple = dummyData[indexPath.row]
        let placeModel = Place(
            placeId: UUID().uuidString, // 임시 고유 ID
            placeName: placeTuple.title,
            placeAddress: "테스트 주소", // 없어도 되는 경우 "" 가능
            latitude: 0.0, // 테스트용 값
            longitude: 0.0,
            category: "기타",
            addedDate: Date(),
            likedCount: nil,
            naviLink: nil,
            instaLink: nil,
            bookLink: nil,
            imageURL: nil // 또는 "https://~~" 형태로 테스트용 이미지 URL 넣어도 됨
        )
        
        cell.configure(with: placeModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("사용자가 \(dummyData[indexPath.row]) 셀을 눌렀습니다.")
    }
}


