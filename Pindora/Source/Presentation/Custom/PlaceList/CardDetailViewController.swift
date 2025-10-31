//
//  CardDetailViewController.swift
//  Pindora
//
//  Created by eunchanKim on 7/29/25.
//

import UIKit
import Combine
import SwiftUI

final class CardDetailViewController: UIViewController {
    weak var coordinator: CardDetailCoordinating?
    private let viewModel: CardDetailViewModel
    private let customView = CardDetailView()
    private var cancellable: Set<AnyCancellable> = []
    private var hostingController: UIHostingController<ReviewContentView>?
    
    // MARK: - Subjects (Input 소스)
    private let addButtonSubject = PassthroughSubject<Void, Never>()
    private let toMapViewButtonSubject = PassthroughSubject<Void, Never>()
    private let confirmButtonSubject = PassthroughSubject<Void, Never>()
    private var place: Place
    
    // MARK: - Initializer
    init(viewModel: CardDetailViewModel, place: Place) {
        self.viewModel = viewModel
        self.place = place
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
        buttonTargets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("CardDetailViewController")
    }
    
    // MARK: - Bindings
    
    private func bindSwiftUIView() {
        // 1) SwiftUI 뷰 생성 + 콜백 주입
        let swiftUIView = ReviewContentView(
            onContinue: { [weak self] in
                self?.confirmButtonSubject.send()
            },
            onClose: { [weak self] in
                self?.hideReview()
            }
        )
        
        // 2) HostingController로 감싸기
        let hosting = UIHostingController(rootView: swiftUIView)
        self.hostingController = hosting
        
        // 3) 자식으로 추가
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hosting.didMove(toParent: self)
        
        hosting.view.alpha = 0
        UIView.animate(withDuration: 0.2) {
            hosting.view.alpha = 1
        }
    }
    
    private func hideReview() {
        guard let hosting = hostingController else { return }
        hosting.willMove(toParent: nil)
        
        // (선택) 페이드 아웃
        UIView.animate(withDuration: 0.2, animations: {
            hosting.view.alpha = 0
        }, completion: { _ in
            hosting.view.removeFromSuperview()
            hosting.removeFromParent()
        })
        
        hostingController = nil
    }
    
    private func bindViewModel() {
        let input = CardDetailViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            addButtonTapped: addButtonSubject.eraseToAnyPublisher(),
            toMapButtonTapped: toMapViewButtonSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.title
            .map { $0 as String? } // String -> String?
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: customView.titleLabel)
            .store(in: &cancellable)
        
        output.address
            .map { $0 as String? } // String -> String?
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: customView.addressLabel)
            .store(in: &cancellable)
        
        output.category
            .map { $0 as String? }
            .receive(on: DispatchQueue.main)
            .assign(to: \.title, on: customView.tagLabelView)
            .store(in: &cancellable)
        
        output.gallery
            .receive(on: DispatchQueue.main)
            .sink { [weak self] images in
                guard let self else { return }
                customView.galleryView.bind(to: Just(images).eraseToAnyPublisher())
            }
            .store(in: &cancellable)
        
        output.isSavedPlace
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case true:
                    self.showTopToast("제거 되었습니다")
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    
                case false:
                    self.showTopToast("저장 되었습니다")
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
            .store(in: &cancellable)
    }
    
    // MARK: - Targets
    private func buttonTargets() {
        customView.pinButton.addTarget(self, action: #selector(pinTapped), for: .touchUpInside)
        customView.webButton.addTarget(self, action: #selector(webButtonTapped), for: .touchUpInside)
        customView.flagButton.addTarget(self, action: #selector(addPlaceButtonTapped), for: .touchUpInside)
        customView.toMapViewButton.addTarget(self, action: #selector(toMapViewButtonTapped), for: .touchUpInside)
        customView.addButton.addTarget(self, action: #selector(addReviewButtonTapped), for: .touchUpInside)
    }
    
    @objc private func pinTapped() {
        // TODO: 추후 외부 지도뷰로 연결
        print("tapped")
    }
    
    @objc private func webButtonTapped() {
        // TODO: 추후 웹으로 연결
        print("tapped")
    }
    
    @objc private func addPlaceButtonTapped() {
        print("tapped")
        addButtonSubject.send()
    }
    
    @objc private func toMapViewButtonTapped() {
        print("tapped")
        dismiss(animated: true)
        coordinator?.didTapMapViewButton(place: place)
    }
    
    @objc private func addReviewButtonTapped() {
        print("tapped")
        bindSwiftUIView()
    }
}
