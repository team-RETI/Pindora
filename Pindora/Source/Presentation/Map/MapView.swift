//  MapViewView.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import NMapsMap
import CoreLocation

// MARK: - (C)MapView
final class MapView: UIView {
    
    // MARK: - UI Component
    var mapView = NMFMapView()
    var selectableMarker: SelectableMarker?
    var locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var findLocation = CLLocation()

    var longitude_HVC = 0.0
    var latitude_HVC = 0.0
    var hasFetchedPlaces = false  // 클래스 프로퍼티로 추가

    var isMarkerSelected = false  // 상태 저장용
    var isExpanded = false
    var myLocation = NMFMarker()
    
    let categoryListView = CategoryCellListView()
    var selectedTag: String?
    
    private var placeMarkers: [NMFMarker] = []

    func clearPlaceMarkers() {
        placeMarkers.forEach { $0.mapView = nil }  // 지도에서 제거
        placeMarkers.removeAll()
    }
    
    let locationButton: UIButton = {
        let button = UIButton()
        button.configuration = .locationButtonStyle()
        button.addShadow()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let tagToggleButton: UIButton = {
        let button = UIButton()
        button.configuration = .tagStyle1(title: "카테고리를 선택해주세요")
        button.addShadow()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var tagStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
        
    let tagScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        mapView.touchDelegate = self
        
        // delegate 설정
        locationManager.delegate = self
        // 사용자에게 허용 받기 alert 띄우기
        self.locationManager.requestWhenInUseAuthorization()
        requestAuthorization()

        // 내 위치 가져오기
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - (F)UI Setup
    private func setupUI() {
        let location = NMGLatLng(lat: 37.579617, lng: 126.977041)
        
        let photo = UIImage(named: "경복궁") ?? UIImage()
        selectableMarker = SelectableMarker(position: location, image: photo)
        selectableMarker?.attach(to: mapView)
        
        selectableMarker?.marker.touchHandler = { [weak self] _ in
            guard let self = self else { return false }

            // 터치 시 선택 상태를 약간 딜레이 후 적용 (피드백처럼 보이게)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isMarkerSelected.toggle()
                self.selectableMarker?.setSelected(self.isMarkerSelected)
            }

            return true
        }
        
        //x,y : 37.17555079934496,127.12561734444992
        // 위도, 경도 가져오기
        let latitude = locationManager.location?.coordinate.latitude ?? 0 //37.5759
        let longitude = locationManager.location?.coordinate.longitude ?? 0 //126.9769
        print("x,y : \(latitude),\(longitude)")
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude), zoomTo: 15.0)
        mapView.moveCamera(cameraUpdate)
        cameraUpdate.animation = .easeIn
        
        // 내 위치 마커 그리기
        let customIcon = MarkerIconFactory.makeCustomUserIcon(from: UIImage(named: "아바타2") ?? UIImage())
        myLocation.position = NMGLatLng(lat: latitude, lng: longitude)
        myLocation.iconImage = NMFOverlayImage(image: customIcon)
        myLocation.width = 64
        myLocation.height = 64
        myLocation.anchor = CGPoint(x: 0.5, y: 1.0)
        
        myLocation.mapView = mapView
        
        addSubview(mapView)
        addSubview(locationButton)
        addSubview(tagToggleButton)
        addSubview(categoryListView)
        categoryListView.isHidden = true
    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        // 지도 제약조건을 Auto Layout으로 설정하고 싶다면:
        mapView.translatesAutoresizingMaskIntoConstraints = false
        categoryListView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            locationButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            locationButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            locationButton.widthAnchor.constraint(equalToConstant: 50),
            locationButton.heightAnchor.constraint(equalToConstant: 50),
            
            tagToggleButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tagToggleButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            tagToggleButton.heightAnchor.constraint(equalToConstant: 35),
            
            categoryListView.centerYAnchor.constraint(equalTo: tagToggleButton.centerYAnchor, constant: 2),
            categoryListView.leadingAnchor.constraint(equalTo: tagToggleButton.trailingAnchor, constant: 8),
            categoryListView.trailingAnchor.constraint(equalTo: trailingAnchor),
            categoryListView.heightAnchor.constraint(equalTo: tagToggleButton.heightAnchor),
        ])
    }
    
    func renderPlacesOnMap(_ places: [KakaoPlace]) {
        // 혹시 모를 중복 방지
        clearPlaceMarkers()

        var newMarkers: [NMFMarker] = []
        for place in places {
            guard let lat = Double(place.y), let lng = Double(place.x) else { continue }

            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: lat, lng: lng)
            marker.iconImage = NMF_MARKER_IMAGE_BLUE // 커스텀이면 NMFOverlayImage 사용
            marker.width = 28
            marker.height = 38
            marker.mapView = mapView
            newMarkers.append(marker)
        }
        placeMarkers = newMarkers
    }
}

extension MapView: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        print("탭: \(latlng.lat), \(latlng.lng)")
        isMarkerSelected = false
        selectableMarker?.setSelected(false)
    }
}

extension MapView: CLLocationManagerDelegate {
    private func requestAuthorization() {
        //정확도 검사
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        //앱 사용할때 권한요청

        switch locationManager.authorizationStatus {
        case .restricted, .denied:
            print("restricted n denied")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            print("권한있음")
            locationManagerDidChangeAuthorization(locationManager)
        default:
            locationManager.startUpdatingLocation()
            print("default")
        }

        locationManagerDidChangeAuthorization(locationManager)

        if(latitude_HVC == 0.0 || longitude_HVC == 0.0){
            print("위치를 가져올 수 없습니다.")
        }

    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            if let currentLocation = locationManager.location?.coordinate{
                print("coordinate")
                longitude_HVC = currentLocation.longitude
                latitude_HVC = currentLocation.latitude
            }
        }
        else{
            print("else")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latitude_HVC =  location.coordinate.latitude
            longitude_HVC = location.coordinate.longitude
        }
    }
}

// MARK: - Naver Local Search API
extension MapView {
    func fetchKakaoPlaces(
        category: String,
        x lng: Double,
        y lat: Double,
        radius: Int = 1500,
        page: Int = 1,
        size: Int = 15,
        completion: @escaping (Result<[KakaoPlace], Error>) -> Void
    ) {
        var comp = URLComponents(string: "https://dapi.kakao.com/v2/local/search/keyword.json") ?? URLComponents()
        comp.queryItems = [
            .init(name: "query", value: category),
            .init(name: "x", value: String(lng)),
            .init(name: "y", value: String(lat)),
            .init(name: "radius", value: String(radius)),
            .init(name: "page", value: String(page)),
            .init(name: "size", value: String(size))
        ]
        guard let url = comp.url else {
            print("❌ 잘못된 URL 구성")
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("KakaoAK d21a4bfef816e5e43a98ad54b649f54d", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: req) { data, _, err in
            if let err = err { return DispatchQueue.main.async { completion(.failure(err)) } }
            guard let data = data else {
                return DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Kakao", code: -1, userInfo: [NSLocalizedDescriptionKey: "no data"])))
                }
            }
            do {
                let res = try JSONDecoder().decode(KakaoSearchResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(res.documents)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    // 응답 모델
    struct KakaoSearchResponse: Decodable {
        let documents: [KakaoPlace]
        let meta: KakaoMeta
    }
    struct KakaoPlace: Decodable {
        let id: String
        let place_name: String
        let x: String   // 경도
        let y: String   // 위도
        let category_name: String?
        let road_address_name: String?
        let address_name: String?
        let phone: String?
    }
    struct KakaoMeta: Decodable {
        let is_end: Bool
    }

}

