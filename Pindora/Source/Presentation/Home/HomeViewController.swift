//  HomeViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import NMapsMap
import Combine
import CoreLocation

final class HomeViewController: UIViewController {
    weak var coordinator: HomeCoordinator?
    private let viewModel: HomeViewModel
    private let customView = HomeView()
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - 하위 VM에 주입하기 위함
    /// SearchDetailViewModel에서 키워드 검색 로직을 담당하도록 분리.
    /// 다만 Search 화면 진입 시 네트워크 지연 없이 바로 추천 키워드를 보여주기 위해
    /// HomeViewController에서 먼저 키워드를 받아 `CurrentValueSubject`에 한번 받아두고 재사용.
    /// 이후 `keywordsPublisher`를 통해 SearchDetailViewModel에 의존성 주입하여
    /// 화면 전환 시 대기 시간 없이 즉시 데이터 표시가 가능하도록 구성.
    private let keywordSubject = CurrentValueSubject<[String], Never>([])
    var keywordsPublisher: AnyPublisher<[String], Never> {
        keywordSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Subjects (Input 소스)
    private let searchTextSubject = PassthroughSubject<String, Never>()
    private let categorySelectedSubject = PassthroughSubject<String, Never>()
    private let mapCenterSubject = PassthroughSubject<CLLocationCoordinate2D, Never>()
    private let sortButtonTapped = PassthroughSubject<Void, Never>()
    
    // MARK: - UI(테이블 뷰)
    private lazy var placeListView: CardCellListView = customView.placeListView
    private var dataSource: UITableViewDiffableDataSource<Place.PlaceSection, Place>?
    private var savedPlaceIDs = Set<String>()
    private var scrollToTopOnUpdate = false
    
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

        // 정렬 버튼 탭 이벤트
        customView.buttonLabel
            .publisher(for: .touchUpInside)
            .sink { [weak self] in
                guard let self = self else { return }
                self.sortButtonTapped.send(())
            }
            .store(in: &cancellable)
        
        // 정렬 버튼 분기
        sortButtonTapped
            .scan(SortOption.distance) { state, _ in
                state == .distance ? .like : .distance
            }
            .sink { [weak self] option in
                guard let self = self else { return }
                var config = UIButton.Configuration.plain()
                config.image = UIImage(named: "sort")
                config.imagePlacement = .trailing
                config.imagePadding = 4
                config.baseForegroundColor = .black
                
                let font = UIFont.systemFont(ofSize: 12, weight: .regular)
                let attributes: [NSAttributedString.Key: Any] = [.font: font]
                let title = (option == .distance) ? "거리순" : "찜순"
                config.attributedTitle = AttributedString(title, attributes: AttributeContainer(attributes))
                
                self.customView.buttonLabel.configuration = config
            }
            .store(in: &cancellable)
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
            categorySelected: categorySelectedSubject.eraseToAnyPublisher(),
            sortButtonTapped: sortButtonTapped.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        // 장소 렌더링
        output.places
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] places in
                self?.applySnapshot(places: places)
            })
            .store(in: &cancellable)
        
        // 위치 스트리밍
        output.location
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coordinate in
                self?.updateMyLocation(location: coordinate)
            }
            .store(in: &cancellable)
        
        output.savedPlace
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ids in
                self?.savedPlaceIDs = ids
                self?.reconfigureAllCells()
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

        output.keywords
            .receive(on: DispatchQueue.main)
            .sink { [weak self] keywords in
                guard let self = self else { return }
                self.keywordSubject.send(keywords)
                print("키워드: \(keywords)")
            }
            .store(in: &cancellable)
    }
    
    @objc private func categoryTapped(_ sender: UIButton) {
        guard let cellView = sender.superview as? CategoryCellView else { return }
        guard let name = cellView.titleText else { return }
        categorySelectedSubject.send(name)
        scrollToTopOnUpdate = true
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
        let searchDetailVM = SearchDetailViewModel(keywordPublisher: keywordsPublisher)
        let searchDetailVC = SearchDetailViewController(viewModel: searchDetailVM)
        let nav = UINavigationController(rootViewController: searchDetailVC)
        nav.modalPresentationStyle = .fullScreen
        
        // 리스트 업데이트
        searchDetailVC.onKeywordSelected = { [weak self] keyword in
            guard let self = self else { return }
            
            // 1. 선택된 키워드 검색창에 표시
            self.customView.searchBarView.textField.text = keyword
            
            // 2. 뷰모델에 이벤트 전달(검색 실행)
            self.searchTextSubject.send(keyword)
        }
        
        present(nav, animated: false, completion: nil)

         // false → 키보드 안 올라오게
         return false
     }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // ✅ 엔터 눌렀을 때 키보드 닫기
        textField.resignFirstResponder()
        
        // 시트로 화면 올라오기
        let searchDetailVM = SearchDetailViewModel(keywordPublisher: keywordsPublisher)
        let searchDetailVC = SearchDetailViewController(viewModel: searchDetailVM)
        let nav = UINavigationController(rootViewController: searchDetailVC)
        nav.modalPresentationStyle = .fullScreen
        
        // 리스트 업데이트
        searchDetailVC.onKeywordSelected = { [weak self] keyword in
            guard let self = self else { return }
            
            // 1. 선택된 키워드 검색창에 표시
            self.customView.searchBarView.textField.text = keyword
            
            // 2. 뷰모델에 이벤트 전달(검색 실행)
            self.searchTextSubject.send(keyword)
        }
        
        present(nav, animated: false, completion: nil)

         // false → 키보드 안 올라오게
         return false
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
            let isSaved = self.savedPlaceIDs.contains(place.placeId)
            cell.configure(with: place, isSaved: isSaved)
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
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            if self.scrollToTopOnUpdate {
                self.scrollListToTop(animated: true)
                self.scrollToTopOnUpdate = false
            }
        })
    }
    
    private func reconfigureAllCells() {
        // 항상 메인스레드에서
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if #available(iOS 15.0, *) {
                guard let dataSource = self.dataSource else { return }

                // 전체 아이템 reconfigure (cellForRow 재호출 없이 셀만 다시 그림)
                var snapshot = dataSource.snapshot()
                let items = snapshot.itemIdentifiers
                snapshot.reconfigureItems(items)
                dataSource.apply(snapshot, animatingDifferences: false)
            } else {
                // iOS 14 이하: 보이는 셀만 수동 갱신
                for cell in self.placeListView.visibleCells {
                    guard
                        let dataSource = self.dataSource,
                        let indexPath = self.placeListView.indexPath(for: cell),
                        let place = dataSource.itemIdentifier(for: indexPath),
                        let card = cell as? CardCellView
                    else { continue }

                    let isSaved = self.savedPlaceIDs.contains(place.placeId)
                    card.configure(with: place, isSaved: isSaved)
                }
            }
        }
    }
    private func scrollListToTop(animated: Bool) {
        guard dataSource?.snapshot().numberOfItems ?? 0 > 0 else { return }
        let top = CGPoint(x: 0, y: -placeListView.adjustedContentInset.top)
        placeListView.setContentOffset(top, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let place = dataSource?.itemIdentifier(for: indexPath) {
            coordinator?.didTapCell(place: place)
        }
    }
}
