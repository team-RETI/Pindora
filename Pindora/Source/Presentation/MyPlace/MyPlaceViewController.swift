//  MyPlaceViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine
import CoreLocation

final class MyPlaceViewController: UIViewController {
    weak var coordinator: MyPlaceCoordinator?
    private let viewModel: MyPlaceViewModel
    private let customView = MyPlaceView()
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - Subjects (Input 소스)
    private let addButtonSubject = PassthroughSubject<String, Never>()
    private let reloadSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - UI(테이블 뷰)
    private lazy var placeListView = customView.placeListView
    private var dataSource: UITableViewDiffableDataSource<Place.PlaceSection, Place>?

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
        placeListView.delegate = self
        configureDataSource()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        addButtonTarget()
        coordinator?.onPlaceSaved = { [weak self] in
            self?.reloadSubject.send(())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("MyPlaceViewController")
    }

    // MARK: - Bindings
    private func bindViewModel() {
        let input = MyPlaceViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            addPlace: addButtonSubject.eraseToAnyPublisher(),
            reload: reloadSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        // 장소 랜더링
        output.places
            .receive(on: DispatchQueue.main)
            .sink { [weak self] places in
                self?.applySnapshot(places: places)
                print("image: \(places.first?.imageURL ?? "")")
            }
            .store(in: &cancellable)
    }
    
    private func addButtonTarget() {
        customView.addButton.addTarget(self, action: #selector(addPlaceButtonTapped), for: .touchUpInside)
    }
    @objc private func addPlaceButtonTapped() {
        print("addPlaceButtonTapped")
            coordinator?.didTapAddPlace()
    }
}

extension MyPlaceViewController: UITableViewDelegate {
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



