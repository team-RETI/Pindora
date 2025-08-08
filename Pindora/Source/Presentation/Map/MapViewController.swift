//  MapViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import NMapsMap
import CoreLocation

final class MapViewController: UIViewController, CLLocationManagerDelegate {
    weak var coordinator: MapCoordinator?
    private let viewModel: MapViewModel
    private let locationManager = CLLocationManager()
    private let customView = MapView()
    
    private var tagsVisible = false
    
    
    // MARK: - Initializer
    init(viewModel: MapViewModel) {
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
        customView.locationButton.addTarget(self, action:  #selector(locationButtonTapped), for: .touchUpInside)
        customView.tagToggleButton.addTarget(self, action: #selector(toggleTags), for: .touchUpInside)
        
        selectableHandler()
        requestLocationPermission()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("MapViewController")
    }
    
    // MARK: - Bindings
    private func bindViewModel() {

    }
    
    private func selectableHandler() {
        customView.selectableMarker?.marker.touchHandler = { [weak self] _ in
            guard let self = self else { return false }

            // 터치 시 선택 상태를 약간 딜레이 후 적용 (피드백처럼 보이게)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.customView.isMarkerSelected.toggle()
                self.customView.selectableMarker?.setSelected(self.customView.isMarkerSelected)
                self.coordinator?.didTapPlaceMarker()
                
                print("marker tapped")
            }

            return true
        }
    }

    @objc private func toggleTags() {
        customView.isExpanded.toggle()
        
        if customView.isExpanded {
            // 태그 처음 등장 시, 오른쪽에서 왼쪽으로 슬라이딩되며 나타남
            customView.tagScrollView.alpha = 0
            customView.tagScrollView.transform = CGAffineTransform(translationX: -20, y: 0)
            customView.tagScrollView.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.customView.tagScrollView.alpha = 1
                self.customView.tagScrollView.transform = .identity
            }
            
            customView.setTags(["카페", "박물관", "명소", "공원", "산책로", "맛집"])

        } else {
            // 사라질 때, 왼쪽으로 살짝 이동하며 fade-out
            UIView.animate(withDuration: 0.3, animations: {
                self.customView.tagScrollView.alpha = 0
                self.customView.tagScrollView.transform = CGAffineTransform(translationX: -20, y: 0)
            }) { _ in
                self.customView.tagScrollView.isHidden = true
            }
        }
    }
    
    @objc private func locationButtonTapped() {
        print("location Button Tapped")
//        customView.mapView.locationOverlay.hidden = false
//        customView.mapView.positionMode = .direction // 또는 .normal
    }
    
    private func requestLocationPermission() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}
