//
//  AddPlaceViewController.swift
//  Pindora
//
//  Created by eunchanKim on 7/28/25.
//

import UIKit
import Combine
import CoreLocation
import PhotosUI

final class AddPlaceViewController: UIViewController {
    weak var coordinator: MyPlaceCoordinator?
    private let viewModel: AddPlaceViewModel
    private let customView = AddPlaceView()
    private var cancellable = Set<AnyCancellable>()
    
    private var currentPlace = Place(
        placeId: UUID().uuidString,
        placeName: "경복궁",
        placeAddress: "서울특별시 종로구 사직로 161",
        latitude: 0.0,
        longitude: 0.0,
        category: "관광지",
        addedDate: Date(),
        likedCount: 0,
        imageURL: nil
    )
    
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
        
        let initialPlace = Place(
            placeId: UUID().uuidString,
            placeName: "초기 장소",
            placeAddress: "주소 없음",
            latitude: 0.0,
            longitude: 0.0,
            category: "기타",
            addedDate: Date(),
            likedCount: 0,
            imageURL: nil
        )
        customView.updatePreviewPlace(initialPlace)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customView.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        customView.confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        customView.setImageTapAction(self, action: #selector(selectImageTapped))
        
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
        
        // 주소 검색 → 미리보기 갱신
        output.place
            .sink { [weak self] place in
                guard let self = self else { return }
                self.currentPlace = place
                self.customView.updatePreviewPlace(place)
            }
            .store(in: &cancellable)
        
        // 카테고리 선택 → currentPlace에 반영 + 미리보기 갱신
        output.selectedCategory
            .sink { [weak self] category in
                guard let self = self else { return }
                self.currentPlace = self.currentPlace.withCategory(category)
                self.customView.updatePreviewPlace(self.currentPlace)
            }
            .store(in: &cancellable)
        
        // 저장 결과 처리 (토스트 + dismiss)
        output.saveResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    self.showTopToast("저장되었습니다")
                    self.dismiss(animated: true)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    
                case .failure(let error):
                    if let saveErr = error as? SaveError {
                        switch saveErr {
                        case .missingPlace:
                            self.showTopToast("주소 정보가 없어요, 정확한 주소를 먼저 입력해 주세요")
                        case .missingCategory:
                            self.showTopToast("카테고리를 선택해 주세요")
                        case .backend(let e):
                            self.showTopToast("저장 실패: \(e.localizedDescription)")
                        }
                    } else {
                        self.showTopToast("저장 실패: \(error.localizedDescription)")
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
            .store(in: &cancellable)
    }
    
    private func setupSearchBarTarget() {
        customView.searchBarView.textField.textPublisher
            .debounce(for: .milliseconds(350), scheduler: RunLoop.main)
            .sink { [weak self] query in
                guard let self else { return }

                // 1. ViewModel에도 흘려보내고 (지금처럼)
                self.searchTextSubject.send(query)

                // 2. currentPlace에도 바로 반영
                self.currentPlace = self.currentPlace.withAddress(query)

                // 3. 미리보기 카드 갱신
                self.customView.updatePreviewPlace(self.currentPlace)

                print("주소 업데이트됨: \(self.currentPlace.placeAddress)")
            }
            .store(in: &cancellable)
    }
    
    private func setupCategoryTargets() {
        for categoryView in customView.categoryViews {
            categoryView.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func categoryTapped(_ sender: UIButton) {
        guard let cellView = sender.superview as? CategoryCellView,
              let name = cellView.titleText else { return }

        for view in customView.categoryViews { view.setSelected(false) }
        cellView.setSelected(true)

        currentPlace = currentPlace.withCategory(name)
        customView.updatePreviewPlace(currentPlace)

        categorySelectedSubject.send(name)
    }
    
    @objc private func cancelButtonTapped() {
        print("cancelButtonTapped")
        dismiss(animated: true)
    }
    
    @objc private func confirmButtonTapped() {
        print("confirmButtonTapped")
        print("🟢 현재 Place 상태:\n\(currentPlace.description)")
        viewModel.injectPlace(currentPlace)
        confirmButtonTappedSubject.send()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // 다른 버튼 터치도 인식되도록
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true) // 현재 뷰에서 키보드 내리기
    }
    
    @objc private func selectImageTapped() {
        print("✅ selectImageTapped called")
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension AddPlaceViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let self, let image = object as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    // ✅ 미리보기 이미지 업데이트
                    self.customView.updatePreviewImage(image)
                    
                    // ✅ 저장용 Place에도 반영
                    self.currentPlace = self.currentPlace.withImage("local-selected")
                }
            }
        }
    }
}
