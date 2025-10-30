//  MapViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import NMapsMap
import CoreLocation
import Combine

final class MapViewController: UIViewController {
    weak var coordinator: MapCoordinator?
    private let viewModel: MapViewModel
    private let customView = MapView()
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - Subjects (Input 소스)
    private let categorySelectedSubject = PassthroughSubject<String, Never>()
    private let locationButtonTappedSubject = PassthroughSubject<Void, Never>()
    
    // NaverMap SDK
    var isExpanded = false              // 태그 상태 저장용
    var isMarkerSelected = false        // 마커 상태 저장용
    var selectedTag: String?            // 태그이름 저장용
    var placeMarkers: [SelectableMarker] = []  // 마커 배열
    private weak var currentSelectedMarker: SelectableMarker?
    var myLocation = NMFMarker()        // 내 현재 위치마커
    private let imageCache = NSCache<NSString, UIImage>() // 간단 메모리 캐시
    private let defaultMarkerImage = UIImage(named: "placeholder") ?? UIImage()
    
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
        // map 터치 관련 델리게이트 설정
        customView.mapView.touchDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCategoryTargets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bindViewEvent()
        bindViewModel()
        print("MapViewController")
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        let input = MapViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            locationButtonTapped: locationButtonTappedSubject.eraseToAnyPublisher(),
            categorySelected: categorySelectedSubject.eraseToAnyPublisher(),
        )
        
        let output = viewModel.transform(input: input)
        
        // 카테고리 선택 상태변경
        output.selectedCategory
            .sink { [weak self] selected in
                guard let self else { return }
                // 모든 셀 선택 해제 후 해당 셀만 선택
                for view in self.customView.categoryListView.categoryViews {
                    view.setSelected(view.titleText == selected)
                }
                self.selectedTag = selected
                self.clearPlaceMarkers()
            }
            .store(in: &cancellable)
        
        // 장소 렌더링
        output.places
            .sink { [weak self] places in
                self?.renderPlacesOnMap(places)
            }
            .store(in: &cancellable)
        
        // 위치 스트리밍
        output.location
            .sink { [weak self] coordinate in
                self?.updateMyLocationMarker(to: coordinate)
            }
            .store(in: &cancellable)
    }
    
    private func bindViewEvent() {
        customView.locationButton.addTarget(self, action: #selector(locationButtonAction), for: .touchUpInside)
        customView.tagToggleButton.addTarget(self, action: #selector(toggleTags), for: .touchUpInside)
    }
    
    private func bindMarker(lat: Double, lng: Double) {
        let customIcon = MarkerIconFactory.makeCustomUserIcon(from: UIImage(named: "avatar2") ?? UIImage())
        myLocation.position = NMGLatLng(lat: lat, lng: lng)
        myLocation.iconImage = NMFOverlayImage(image: customIcon)
        myLocation.width = 64
        myLocation.height = 64
        myLocation.anchor = CGPoint(x: 0.5, y: 1.0)
        
        // mapView에 등록
        myLocation.mapView = customView.mapView
    }
    
    private func renderPlacesOnMap(_ places: [Place]) {
        // 혹시 모를 중복 방지
        clearPlaceMarkers()
        
        for place in places {
            let lat = place.latitude
            let lng = place.longitude
            let position = NMGLatLng(lat: lat, lng: lng)
            
            // 마커 썸네일 이미지 준비 (URL or 카테고리 에셋)
            loadMarkerImage(for: place) { [weak self] image in
                guard let self else { return }
                let photo = image ?? self.defaultMarkerImage
                
                let marker = SelectableMarker(position: position, image: photo)
                marker.marker.captionRequestedWidth = 50
                marker.marker.captionText = place.placeName
                marker.marker.isHideCollidedCaptions = true
                
                marker.attach(to: self.customView.mapView)
                self.placeMarkers.append(marker)
                
                // 터치 핸들러는 "방금 만든 marker"를 대상으로 동작해야 함
                marker.marker.touchHandler = { [weak self, weak marker] _ in
                    guard let self, let marker else { return false }
                    
                    // UI는 메인에서
                    DispatchQueue.main.async {
                        // 같은 마커 재탭: 해제
                        if self.currentSelectedMarker === marker {
                            marker.setSelected(false)
                            self.currentSelectedMarker = nil
                        } else {
                            // 이전 선택 해제 후 새 선택
                            self.currentSelectedMarker?.setSelected(false)
                            marker.setSelected(true)
                            self.currentSelectedMarker = marker
                        }

                        // 시트 띄우고, dismiss 시 현재 선택 해제
                        self.coordinator?.didTapPlaceMarker(place: place) { [weak self] in
                            guard let self else { return }
                            self.currentSelectedMarker?.setSelected(false)
                            self.currentSelectedMarker = nil
                        }
                    }
                    return true
                }
            }
        }
    }
    
    func renderPlaceOnMap(_ place: Place) {
        // 혹시 모를 중복 방지
        clearPlaceMarkers()
        
        let lat = place.latitude
        let lng = place.longitude
        let position = NMGLatLng(lat: lat, lng: lng)
        
        let update = NMFCameraUpdate(scrollTo: position, zoomTo: 15)
        update.animation = .easeIn
        customView.mapView.moveCamera(update)
        
        // 마커 썸네일 이미지 준비 (URL or 카테고리 에셋)
        loadMarkerImage(for: place) { [weak self] image in
            guard let self else { return }
            let photo = image ?? self.defaultMarkerImage
            
            let marker = SelectableMarker(position: position, image: photo)
            marker.marker.captionRequestedWidth = 50
            marker.marker.captionText = place.placeName
            marker.marker.isHideCollidedCaptions = true
            
            marker.attach(to: self.customView.mapView)
            self.placeMarkers.append(marker)
            
            // 터치 핸들러는 "방금 만든 marker"를 대상으로 동작해야 함
            marker.marker.touchHandler = { [weak self, weak marker] _ in
                guard let self, let marker else { return false }
                
                // UI는 메인에서
                DispatchQueue.main.async {
                    // 같은 마커 재탭: 해제
                    if self.currentSelectedMarker === marker {
                        marker.setSelected(false)
                        self.currentSelectedMarker = nil
                    } else {
                        // 이전 선택 해제 후 새 선택
                        self.currentSelectedMarker?.setSelected(false)
                        marker.setSelected(true)
                        self.currentSelectedMarker = marker
                    }
                    
                    // 시트 띄우고, dismiss 시 현재 선택 해제
                    self.coordinator?.didTapPlaceMarker(place: place) { [weak self] in
                        guard let self else { return }
                        self.currentSelectedMarker?.setSelected(false)
                        self.currentSelectedMarker = nil
                    }
                }
                return true
            }
        }
    }
    
    private func clearPlaceMarkers() {
        placeMarkers.forEach { $0.marker.mapView = nil }  // 지도에서 제거
        placeMarkers.removeAll()
    }
    
    /// 내 위치 마커를 갱신하여 지도에 표시
    private func updateMyLocationMarker(to coord: CLLocationCoordinate2D) {
        let customIcon = MarkerIconFactory.makeCustomUserIcon(
            from: UIImage(named: "avatar2") ?? UIImage()
        )
        myLocation.position = NMGLatLng(lat: coord.latitude, lng: coord.longitude)
        myLocation.iconImage = NMFOverlayImage(image: customIcon)
        myLocation.width = 64
        myLocation.height = 64
        myLocation.anchor = CGPoint(x: 0.5, y: 1.0)
        resetCameraToMyLocation()
        myLocation.mapView = customView.mapView
    }
    /// 카메라 위치 현재위치로 조정
    private func resetCameraToMyLocation() {
        let update = NMFCameraUpdate(scrollTo: myLocation.position, zoomTo: 15)
        update.animation = .easeIn
        customView.mapView.moveCamera(update)
    }
    /// 마커에 사용할 이미지를 로드 (URL → 다운로드, 실패 시 카테고리 기본 이미지)
    private func loadMarkerImage(for place: Place, completion: @escaping (UIImage?) -> Void) {
        // 1) URL이 있으면 우선 시도
        if let raw = place.imageURL?.trimmingCharacters(in: .whitespacesAndNewlines),
           raw.isEmpty == false {

            // ATS 대비: http -> https 강제
            let secure = raw.hasPrefix("http://")
            ? raw.replacingOccurrences(of: "http://", with: "https://")
            : raw

            // 캐시 hit
            if let cached = imageCache.object(forKey: NSString(string: secure)) {
                completion(cached)
                return
            }

            if let url = URL(string: secure) {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let self, let data, let img = UIImage(data: data) else {
                        // 실패 시 카테고리 기본 이미지로 대체
//                        completion(self?.categoryFallbackImage(for: place.category))
                        return
                    }
                    self.imageCache.setObject(img, forKey: NSString(string: secure))
                    DispatchQueue.main.async { completion(img) }
                }.resume()
                return
            }
        }

        // 2) URL이 없거나 실패 → 카테고리 에셋
//        completion(categoryFallbackImage(for: place.category))
    }
    
    @objc private func toggleTags() {
        isExpanded.toggle()
        
        if isExpanded {
            customView.categoryListView.alpha = 0
            customView.categoryListView.transform = CGAffineTransform(translationX: -20, y: 0)
            customView.categoryListView.isHidden = false
            customView.tagToggleButton.configuration = .tagStyle2()
            
            UIView.animate(withDuration: 0.3) {
                self.customView.categoryListView.alpha = 1
                self.customView.categoryListView.transform = .identity
            }
            
        } else {
            customView.tagToggleButton.configuration = .tagStyle1(title: selectedTag ?? "카테고리를 선택해주세요")
            UIView.animate(withDuration: 0.3, animations: {
                self.customView.categoryListView.alpha = 0
                self.customView.categoryListView.transform = CGAffineTransform(translationX: -20, y: 0)
            }) { _ in
                self.customView.categoryListView.isHidden = true
            }
        }
    }
    
    private func setupCategoryTargets() {
        for categoryView in customView.categoryListView.categoryViews {
            categoryView.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func categoryTapped(_ sender: UIButton) {
        guard let cellView = sender.superview as? CategoryCellView else { return }
        guard let name = cellView.titleText else { return }
        categorySelectedSubject.send(name)
    }
    
    @objc private func locationButtonAction() {
        locationButtonTappedSubject.send()
        resetCameraToMyLocation()
    }
}
extension MapViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
    }
}

