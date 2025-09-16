//
//  AddPlaceViewController.swift
//  Pindora
//
//  Created by eunchanKim on 7/28/25.
//

import UIKit
import Combine
import CoreLocation

final class AddPlaceViewController: UIViewController {
    weak var coordinator: MyPlaceCoordinator?
    private let viewModel: AddPlaceViewModel
    private let customView = AddPlaceView()
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - Subjects (Input 소스)
    private let searchTextSubject = PassthroughSubject<String, Never>()
    private let categorySelectedSubject = PassthroughSubject<String, Never>()
    private let confirmButtonTappedSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Initializer
    init(viewModel: AddPlaceViewModel) {
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
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customView.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        customView.confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        setupTapGesture()
        setupCategoryTargets()
        setupSearchBarTarget()
        print("AddPlaceViewController")
    }

    // MARK: - Bindings
    private func bindViewModel() {
        let input = AddPlaceViewModel.Input(
            keyword: searchTextSubject.eraseToAnyPublisher(),
            categorySelected: categorySelectedSubject.eraseToAnyPublisher(),
            confirmButtonTapped: confirmButtonTappedSubject.eraseToAnyPublisher()
            )
        
        let output = viewModel.transform(input: input)
        
        output.place
            .handleEvents(receiveSubscription: { _ in print("🧲 subscribed: output.place") })
            .sink { place in
                print("📦 place out:", place)
            }
            .store(in: &cancellable)

        output.selectedCategory
            .handleEvents(receiveSubscription: { _ in print("🧲 subscribed: output.selectedCategory") })
            .sink { cat in
                print("🏷️ out selectedCategory:", cat)
            }
            .store(in: &cancellable)
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
    
    private func setupCategoryTargets() {
        for categoryView in customView.categoryViews {
            categoryView.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        }
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        guard let cellView = sender.superview as? CategoryCellView else { return }
        guard let name = cellView.titleText else { return }
        categorySelectedSubject.send(name)
    }
    
    @objc private func cancelButtonTapped() {
        print("cancelButtonTapped")
        dismiss(animated: true)
    }
    
    @objc private func confirmButtonTapped() {
        print("confirmButtonTapped")
        confirmButtonTappedSubject.send()
        dismiss(animated: true)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // 다른 버튼 터치도 인식되도록
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true) // 현재 뷰에서 키보드 내리기
    }
}
