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
    private let confirmButtonSubject = PassthroughSubject<ReviewPayload, Never>()
    private let deleteButtonSubject = PassthroughSubject<ReviewPayload, Never>()
    private var place: Place
    private var reviewData: ReviewPayload?
    
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
    private func bindSwiftUIView(existingReview: ReviewPayload? = nil) {
        // 1) SwiftUI View 생성
        let swiftUIView: ReviewContentView

        if let existing = existingReview {
            // ✅ 기존 리뷰 보기 모드
            swiftUIView = ReviewContentView(
                mode: .view(existing: existing),
                onSave: { [weak self] updated in
                    print("수정된 점수:", updated.rating)
                    print("수정된 리뷰:", updated.context)
                    self?.confirmButtonSubject.send(updated)
                    self?.hideReview()
                },
                onDelete: { [weak self] deleted in
                    print("삭제 요청된 리뷰:", deleted)
                    // 필요 시 삭제 이벤트 전달
                    self?.deleteButtonSubject.send(deleted)
                    self?.hideReview()
                    self?.reviewData = nil
                },
                onClose: { [weak self] in
                    self?.hideReview()
                }
            )
        } else {
            // ✅ 새 리뷰 생성 모드
            swiftUIView = ReviewContentView(
                mode: .create,
                onSave: { [weak self] payload in
                    print("새 리뷰 점수:", payload.rating)
                    print("새 리뷰 내용:", payload.context)
                    self?.confirmButtonSubject.send(payload)
                    self?.hideReview()
                },
                onDelete: nil,
                onClose: { [weak self] in
                    self?.hideReview()
                }
            )
        }

        // 2) HostingController로 감싸기
        let hosting = UIHostingController(rootView: swiftUIView)
        self.hostingController = hosting

        // 3) 자식 뷰로 추가
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

        // 4) 부드러운 등장 애니메이션
        hosting.view.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
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
            toMapButtonTapped: toMapViewButtonSubject.eraseToAnyPublisher(),
            confirmReviewButtonTapped: confirmButtonSubject.eraseToAnyPublisher(),
            deleteReviewButtonTapped: deleteButtonSubject.eraseToAnyPublisher()
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
        
        output.reviewData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reviewData in
                guard let self else { return }
                self.reviewData = reviewData
            }
            .store(in: &cancellable)
        
        // 1) rating -> UIImage?
        let faceImageStream = output.reviewRating
            .map { rating -> UIImage? in
                guard let rating = rating else { return nil }
                switch rating {
                case 0...2: return UIImage(named: "face_happy")
                case 3...4: return UIImage(named: "face_smile")
                case 5...6: return UIImage(named: "face_soso")
                case 7...8: return UIImage(named: "face_sad")
                default:    return UIImage(named: "face_angry")
                }
            }
            .eraseToAnyPublisher()
        
        // 2) addedDate -> "yy.MM.dd" 문자열 (nil이면 표시 안 함)
        let dateTextStream = output.addedDate
            .map { date -> String in
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.dateFormat = "yy.MM.dd"
                return formatter.string(from: date)
            }
            .eraseToAnyPublisher()
        
        // 3) 둘을 합쳐 버튼 구성
        Publishers.CombineLatest(faceImageStream, dateTextStream)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image, dateText in
                guard let self = self else { return }
                let btn = self.customView.reviewLabelButton
                var config = UIButton.Configuration.filled()
                config.baseBackgroundColor = .white
                config.baseForegroundColor = .black
                config.cornerStyle = .capsule
                
                config.image = image
                config.imagePlacement = .leading
                config.imagePadding = 5
                
                var attr = AttributedString(dateText) // ← 비옵셔널 String 그대로 사용
                attr.font = .systemFont(ofSize: 10, weight: .light)
                config.attributedTitle = attr
                
                config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 3, bottom: 6, trailing: 3)
                
                if let image = image {
                    // 리뷰가 있는 경우 흰색 버튼
                    config.baseBackgroundColor = .white
                    config.baseForegroundColor = .black
                    config.image = image
                    btn.alpha = 1.0
                    
                } else {
                    // 없는 경우 투명색
                    config.baseBackgroundColor = UIColor.white.withAlphaComponent(0.15)
                    config.baseForegroundColor = UIColor.black.withAlphaComponent(0.4)
                    config.attributedTitle = ""
                    btn.alpha = 0.6
                }

                btn.configuration = config
                
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
        customView.reviewLabelButton.addTarget(self, action: #selector(reviewButtonTapped), for: .touchUpInside)
    }
    
    @objc private func pinTapped() {
        // TODO: 추후 외부 네비게이션 앱으로 연결
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
        bindSwiftUIView(existingReview: nil)
    }
    
    @objc private func reviewButtonTapped() {
        print("tapped")
        if reviewData != nil {
            bindSwiftUIView(existingReview: reviewData)
        }
    }
}
