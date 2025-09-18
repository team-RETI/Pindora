//  HomeViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import NMapsMap
import Combine
import CoreLocation

final class HomeViewController: UIViewController, UITextFieldDelegate {
    weak var coordinator: HomeCoordinator?
    private let viewModel: HomeViewModel
    private let customView = HomeView()
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - Subjects (Input 소스)
    private let searchTextSubject = PassthroughSubject<String, Never>()
    private let categorySelectedSubject = PassthroughSubject<String, Never>()
    private let mapCenterSubject = PassthroughSubject<CLLocationCoordinate2D, Never>()
    
    // MARK: - UI(테이블 뷰)
    private lazy var placeListView: CardCellListView = customView.placeListView
    private var dataSource: UITableViewDiffableDataSource<Place.PlaceSection, Place>?
    
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
        // 장소 리스트 관련 델리게이트 설정
        placeListView.delegate = self
        configureDataSource()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        customView.searchBarView.textField.delegate = self
        viewModel.fetchPlaces()
        viewModel.fetchKeywords()
        setupSortButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSearchBarTarget()
        setupCategoryTarget()
        print("HomeViewController")
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        let input = HomeViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            keyword: searchTextSubject.eraseToAnyPublisher(),
            mapCenter: mapCenterSubject.eraseToAnyPublisher(),
            categorySelected: categorySelectedSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        // 장소 렌더링
        output.places
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] places in
                self?.applySnapshot(places: places)
                self?.viewModel.places = places // TODO:
            })
            .store(in: &cancellable)
        
        // 위치 스트리밍
        output.location
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coordinate in
                self?.updateMyLocation(location: coordinate)
            }
            .store(in: &cancellable)
        
        // 카테고리 선택 상태변경
        output.selectedCategory
            .sink { [weak self] selected in
                guard let self else { return }
                // 모든 셀 선택 해제 후 해당 셀만 선택
                for view in self.customView.categoryListView.categoryViews {
                    view.setSelected(view.titleText == selected)
                }
            }
            .store(in: &cancellable)
    }
    
    @objc private func categoryTapped(_ sender: UIButton) {
        guard let cellView = sender.superview as? CategoryCellView else { return }
        guard let name = cellView.titleText else { return }
        categorySelectedSubject.send(name)
    }
    private func setupCategoryTarget() {
        for categoryView in customView.categoryListView.categoryViews {
            categoryView.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        }
    }
    private func setupSearchBarTarget() {
        // 사용자가 타이핑할 때마다 문자열을 방출하는 퍼블리셔
        customView.searchBarView.textField.textPublisher
            // 0.35초 동안 입력이 멈출 때만 이벤트를 흘려보냄
            .debounce(for: .milliseconds(350), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.searchTextSubject.send(query)
            }
            .store(in: &cancellable)
    }
    private func updateMyLocation(location: CLLocationCoordinate2D) {
        mapCenterSubject.send(location)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        // 키보드 자동 올라오기 방지
        textField.resignFirstResponder()
        
        // 시트로 화면 올라오기
        let searchDetailVC = SearchDetailViewController(viewModel: viewModel)
        
        // 리스트 업데이트
        searchDetailVC.onKeywordSelected = { [weak self] keyword in
            self?.performSearch(keyword: keyword)
        }
        
        let nav = UINavigationController(rootViewController: searchDetailVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: false, completion: nil)
    
         // false → 키보드 안 올라오게
         return false
     }
    
    private func setupSortButton() {
        customView.sortButton.addTarget(self, action: #selector(didTapSortButton), for: .touchUpInside)
    }
    
    @objc private func didTapSortButton() {
        customView.toggleSortType()
        let type = customView.sortType
        print("정렬 타입 변경됨: \(type)")
        
        // ✅ ViewModel 에 정렬 요청 보내기
        switch type {
        case .distance:
            viewModel.sortPlacesByDistance()
        case .likes:
            viewModel.sortPlacesByLikes()
        }
        
        applySnapshot(places: viewModel.places)
    }
}

extension HomeViewController: UITableViewDelegate {
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Place.PlaceSection, Place>(
            tableView: placeListView
        ) { tableView, indexPath, place in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "CardCellView",
                for: indexPath
            ) as? CardCellView else {
                return UITableViewCell()
            }

            // 셀 구성
            cell.configure(with: place)
            cell.setImage(
                urlString: place.imageURL,
                category: place.category
            )
            return cell
        }

        // 초기 스냅샷(빈 값)
        var snapshot = NSDiffableDataSourceSnapshot<Place.PlaceSection, Place>()
        snapshot.appendSections([.main])
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func applySnapshot(places: [Place]) {
        var snapshot = NSDiffableDataSourceSnapshot<Place.PlaceSection, Place>()
        snapshot.appendSections([.main])
        snapshot.appendItems(places, toSection: .main)

        UIView.transition(with: placeListView,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
            // Diffable 자체 애니메이션은 끄기
            self?.dataSource?.apply(snapshot, animatingDifferences: false)
        })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let place = dataSource?.itemIdentifier(for: indexPath) {
            coordinator?.didTapCell(place: place)
        }
    }
}

extension HomeViewController {
    func performSearch(keyword: String) {
        searchTextSubject.send(keyword)
    }
}


