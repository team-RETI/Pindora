//  HomeViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit

final class HomeViewController: UIViewController {
    weak var coordinator: HomeCoordinator?
    private let viewModel: HomeViewModel
    private let customView = HomeView()
    
    private lazy var placeListView: CardCellListView = customView.placeListView
    private let dummyData: [(title: String, description: String, imageName: String)] = [
        ("카페 드롭탑", "분위기 좋은 루프탑 카페", "경복궁"),
        ("연남동 돈까스", "수요미식회에도 나온 맛집", "경복궁고화질"),
        ("책방 무대륙", "힐링하기 좋은 독립 서점", "스타필드"),
        ("서울숲 카페", "분위기 좋은 루프탑 카페", "남산타워"),
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("HomeViewController")
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("사용자가 \(dummyData[indexPath.row]) 셀을 눌렀습니다.")
        coordinator?.didTapCell()
    }
}

