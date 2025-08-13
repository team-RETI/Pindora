//  MapViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import NMapsMap
import CoreLocation
import Combine

final class MapViewController: UIViewController, CLLocationManagerDelegate {
    weak var coordinator: MapCoordinator?
    private let viewModel: MapViewModel
    private let locationManager = CLLocationManager()
    private let kakaoApiManager =  KakaoSearchAPIManager.shared
    private var cancellables = Set<AnyCancellable>()
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
        customView.clearPlaceMarkers()
        kakaoApiManager
            .searchPlaces(keyword: name,
                          x: customView.longitude_HVC,
                          y: customView.latitude_HVC,)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("에러:", error.message)
                }
            } receiveValue: { places in
                print("받은 장소 수:", places.count)
                self.customView.renderPlacesOnMap(places)
            }
            .store(in: &cancellables)
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
