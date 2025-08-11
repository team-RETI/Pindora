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
        setupCategoryTargets()
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
    
    private func setupCategoryTargets() {
        for categoryView in customView.categoryListView.categoryViews {
            categoryView.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func categoryTapped(_ sender: UIButton) {
        guard let cellView = sender.superview as? CategoryCellView else { return }

        for view in customView.categoryListView.categoryViews { view.setSelected(false) }
        cellView.setSelected(true)

        guard let name = cellView.titleText else { return }
        customView.selectedTag = name

        // ✅ 이전 카테고리 마커 즉시 제거
        customView.clearPlaceMarkers()

        // 요청 식별자(선택사항: 레이스 방지용)
        let requestCategory = name
        let currentCategoryRequestId = UUID() // 프로퍼티로 하나 선언해두세요
        let requestId = currentCategoryRequestId

        customView.fetchKakaoPlaces(category: name,
                                    x: customView.longitude_HVC,
                                    y: customView.latitude_HVC,
                                    radius: 1500) { [weak self] result in
            guard let self = self else { return }
            // ✅ 레이스 보호: 탭이 여러 번 일어났을 때, 최신 요청만 반영
            guard requestId == currentCategoryRequestId else { return }

            switch result {
            case .success(let places):
                customView.renderPlacesOnMap(places)
            case .failure(let error):
                print("fetch error:", error)
            }
        }
    }
    
    @objc private func toggleTags() {
        customView.isExpanded.toggle()
        
        if customView.isExpanded {
            customView.categoryListView.alpha = 0
            customView.categoryListView.transform = CGAffineTransform(translationX: -20, y: 0)
            customView.categoryListView.isHidden = false
            customView.tagToggleButton.configuration = .tagStyle2()
    
            UIView.animate(withDuration: 0.3) {
                self.customView.categoryListView.alpha = 1
                self.customView.categoryListView.transform = .identity
            }
            
        } else {
            customView.tagToggleButton.configuration = .tagStyle1(title: customView.selectedTag ?? "카테고리를 선택해주세요")
            UIView.animate(withDuration: 0.3, animations: {
                self.customView.categoryListView.alpha = 0
                self.customView.categoryListView.transform = CGAffineTransform(translationX: -20, y: 0)
            }) { _ in
                self.customView.categoryListView.isHidden = true
            }
        }
    }
    
    @objc private func locationButtonTapped() {
        guard let loc = locationManager.location else { return }
        let latLng = NMGLatLng(lat: loc.coordinate.latitude, lng: loc.coordinate.longitude)

        let update = NMFCameraUpdate(scrollTo: latLng, zoomTo: 15)
        update.animation = .easeIn
        customView.mapView.moveCamera(update)

        // 이미 만든 마커만 위치만 갱신
        customView.myLocation.position = latLng
    }
    
    private func requestLocationPermission() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}
