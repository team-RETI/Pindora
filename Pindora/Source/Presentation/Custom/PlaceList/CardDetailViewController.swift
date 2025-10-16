//
//  CardDetailViewController.swift
//  Pindora
//
//  Created by eunchanKim on 7/29/25.
//

import UIKit
import Combine

final class CardDetailViewController: UIViewController {
    weak var coordinator: CardDetailCoordinating?
    private let viewModel: CardDetailViewModel
    private let customView = CardDetailView()
    private var cancellable: Set<AnyCancellable> = []
    
    // MARK: - Subjects (Input 소스)
    private let addButtonSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Initializer
    init(viewModel: CardDetailViewModel, place: Place) {
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
        buttonTargets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("CardDetailViewController")
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        let input = CardDetailViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            addButtonTapped: addButtonSubject.eraseToAnyPublisher()
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
    }
    
    @objc private func pinTapped() {
        // TODO: 추후 외부 지도뷰로 연결
        print("tapped")
        dismiss(animated: true)
    }
    
    @objc private func webButtonTapped() {
        // TODO: 추후 웹으로 연결
        print("tapped")
        dismiss(animated: true)
    }
    
    @objc private func addPlaceButtonTapped() {
        print("tapped")
        addButtonSubject.send()
    }
}
