//  HomeViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    weak var coordinator: HomeCoordinator?
    private let viewModel: HomeViewModel
    private let customView = HomeView()
    
    private lazy var placeListView: CardCellListView = customView.placeListView
    private var cancellables = Set<AnyCancellable>()
    private var placeList: [Place] = []
    
    private let dummyData: [(category: String, likedCount: Int, title: String, address: String, imageURL: String, date: Date)] = [
        ("관광지",159,"경복궁", "서울특별시 종로구 사직로 161", "sample1", ISO8601DateFormatter().date(from: "2025-08-01T00:00:00Z") ?? Date()),
        ("카페",55,"스타벅스 시청점", "도로명서울 중구 을지로 19 삼성화재삼성빌딩 1층", "sample6", Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()),
        ("공원",595,"여의도 한강공원", "서울 영등포구 여의동로 330", "sample9", Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()),
        ("관광지",111,"남산타워", "서울 영등포구 여의동로 330", "sample4", Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()),
    ]
    
    // MARK: - Initializer
    init(viewModel: HomeViewModel) {
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
        placeListView.dataSource = self
        placeListView.delegate = self
        bindViewModel()
        viewModel.fetchPlaces()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for categoryView in customView.categoryListView.categoryViews {
            categoryView.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        }

        print("HomeViewController")
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.$places
            .receive(on: DispatchQueue.main)
            .sink { [weak self] places in
                self?.placeList = places
                self?.placeListView.reloadData()
            }.store(in: &cancellables)
    }
    
    @objc private func categoryTapped(_ sender: UIButton) {
        guard let cellView = sender.superview as? CategoryCellView else {
            print("❌ CategoryCellView로 캐스팅 실패 - sender.superview: \(String(describing: sender.superview))")
            return
        }

        for view in customView.categoryListView.categoryViews {
            view.setSelected(false)
        }
        
        cellView.setSelected(true)

        let selectedTitle = cellView.titleText
        print("✅ 선택된 카테고리: \(selectedTitle ?? "-")")
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return placeList.count
        // 목업 테스트용
        return dummyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardCellView", for: indexPath) as? CardCellView else {
            return UITableViewCell()
        }
        
        let placeTuple = dummyData[indexPath.row]
        let placeModel = Place(
            placeId: UUID().uuidString, // 임시 고유 ID
            placeName: placeTuple.title,
            placeAddress: placeTuple.address,
            latitude: 0.0,
            longitude: 0.0,
            category: placeTuple.category,
            addedDate: placeTuple.date,
            likedCount: placeTuple.likedCount,
            naviLink: nil,
            instaLink: nil,
            bookLink: nil,
            imageURL: placeTuple.imageURL // 또는 "https://~~" 형태로 테스트용 이미지 URL 넣어도 됨
        )
        cell.configure(with: placeModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("사용자가 \(dummyData[indexPath.row]) 셀을 눌렀습니다.")
        coordinator?.didTapCell()
    }
}

