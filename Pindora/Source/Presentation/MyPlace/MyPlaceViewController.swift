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
    private let dummyData: [(category: String, likedCount: Int, title: String, description: String, imageName: String, date: String)] = [
        ("관광지",159,"경복궁", "서울특별시 종로구 사직로 161", "경복궁", "2주전"),
        ("카페",55,"스타벅스 시청점", "도로명서울 중구 을지로 19 삼성화재삼성빌딩 1층", "스타벅스 시청", "어제"),
        ("공원",595,"여의도 한강공원", "서울 영등포구 여의동로 330", "여의도 한강공원","한달전"),
        ("관광지",111,"남산타워", "서울 영등포구 여의동로 330", "남산타워", "3일전"),
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
        
        let place = dummyData[indexPath.row]
        let placeModel = PlaceModel(category: place.category, likedCount: place.likedCount, title: place.title, description: place.description, imageName: place.imageName, date: place.date)
        
        cell.configure(with: placeModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("사용자가 \(dummyData[indexPath.row]) 셀을 눌렀습니다.")
    }
}


