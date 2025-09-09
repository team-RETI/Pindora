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
    
    // MARK: - Subjects (Input 소스)
    private let searchTextSubject = PassthroughSubject<String, Never>()
    private let categorySelectedSubject = PassthroughSubject<String, Never>()
    
    private lazy var placeListView: CardCellListView = customView.placeListView
    private var cancellable = Set<AnyCancellable>()
    private var placeList: [Place] = []
    
//    private let dummyData: [(category: String, likedCount: Int, title: String, address: String, imageURL: String, date: Date)] = [
//        ("관광지",159,"경복궁", "서울특별시 종로구 사직로 161", "sample1", ISO8601DateFormatter().date(from: "2025-08-01T00:00:00Z") ?? Date()),
//        ("카페",55,"스타벅스 시청점", "도로명서울 중구 을지로 19 삼성화재삼성빌딩 1층", "sample6", Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()),
//        ("공원",595,"여의도 한강공원", "서울 영등포구 여의동로 330", "sample9", Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()),
//        ("관광지",111,"남산타워", "서울 영등포구 여의동로 330", "sample4", Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()),
//    ]
    
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
        setupSearchBarTarget()
        setupCategoryTargets()
        print("HomeViewController")
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        let input = HomeViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            keyword: searchTextSubject.eraseToAnyPublisher(),
            categorySelected: categorySelectedSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.places
            .sink(receiveValue: { [weak self] places in
                self?.placeList = places
                self?.placeListView.reloadData()
            })
            .store(in: &cancellable)
        
        output.location
            .sink { [weak self] coordinate in
//                self?.updateMyLocation(lat: coordinate.coordinate.latitude, lng: coordinate.coordinate.longitude)
//                self?.firstCoordinate = coordinate.coordinate
            }
            .store(in: &cancellable)
        
        output.selectedCategory
            .sink { [weak self] selected in
                guard let self else { return }
                // 모든 셀 선택 해제 후 해당 셀만 선택
                for view in self.customView.categoryListView.categoryViews {
                    view.setSelected(view.titleText == selected)
                }
//                self.selectedTag = selected
//                self.clearPlaceMarkers()
            }
            .store(in: &cancellable)
        
        //        viewModel.$places
        //            .receive(on: DispatchQueue.main)
        //            .sink { [weak self] places in
        //                self?.placeList = places
        //                self?.placeListView.reloadData()
        //            }.store(in: &cancellables)
    }
    
    @objc private func categoryTapped(_ sender: UIButton) {
        guard let cellView = sender.superview as? CategoryCellView else { return }
        guard let name = cellView.titleText else { return }
        categorySelectedSubject.send(name)
    }
    private func setupCategoryTargets() {
        for categoryView in customView.categoryListView.categoryViews {
            categoryView.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        }
    }
    private func setupSearchBarTarget() {
        customView.searchBarView.textField.textPublisher
            .debounce(for: .milliseconds(350), scheduler: RunLoop.main)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .removeDuplicates()
            .filter { !$0.isEmpty } // 빈 검색어 건너뜀
            .sink { [weak self] query in
                self?.searchTextSubject.send(query) // ✅ 키워드만 전달
            }
            .store(in: &cancellable)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardCellView", for: indexPath) as? CardCellView else {
            return UITableViewCell()
        }
        
        let placeTuple = placeList[indexPath.row]
        let placeModel = Place(
            placeId: UUID().uuidString, // 임시 고유 ID
            placeName: placeTuple.placeName,
            placeAddress: placeTuple.placeAddress,
            latitude: 0.0,
            longitude: 0.0,
            category: placeTuple.category,
            addedDate: placeTuple.addedDate,
            likedCount: placeTuple.likedCount,
            naviLink: nil,
            instaLink: nil,
            bookLink: nil,
//            imageURL: placeTuple.imageURL // 또는 "https://~~" 형태로 테스트용 이미지 URL 넣어도 됨
        )

        cell.setImage(urlString: placeTuple.imageURL ?? "placeholder") // 또는 placeholder 세팅
        cell.configure(with: placeModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("사용자가 \(placeList[indexPath.row]) 셀을 눌렀습니다.")
        coordinator?.didTapCell()
    }
    
    
}

