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

    let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let tagToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("  🏷 관광지  >", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var tagStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
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
        locationManager.delegate = self
        
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
//        let location = NMGLatLng(lat: 37.579617, lng: 126.977041)
//        
//        let photo = UIImage(named: "경복궁") ?? UIImage()
//        selectableMarker = SelectableMarker(position: location, image: photo)
//        selectableMarker?.attach(to: mapView)
//        
//        selectableMarker?.marker.touchHandler = { [weak self] _ in
//            guard let self = self else { return false }
//
//            // 터치 시 선택 상태를 약간 딜레이 후 적용 (피드백처럼 보이게)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.isMarkerSelected.toggle()
//                self.selectableMarker?.setSelected(self.isMarkerSelected)
//            }
//
//            return true
//        }
        
        //x,y : 37.17555079934496,127.12561734444992
        // 위도, 경도 가져오기
        let latitude = 37.17555079934496//locationManager.location?.coordinate.latitude ?? 0 //37.5759
        let longitude = 127.12561734444992//locationManager.location?.coordinate.longitude ?? 0 //126.9769
        print("x,y : \(latitude),\(longitude)")
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude), zoomTo: 15.0)
        mapView.moveCamera(cameraUpdate)
        cameraUpdate.animation = .easeIn
        
        // 내 위치 마커 그리기
        let myLocation = NMFMarker()
        let customIcon = MarkerIconFactory.makeCustomUserIcon(from: UIImage(named: "아바타2") ?? UIImage())
        myLocation.position = NMGLatLng(lat: latitude, lng: longitude)
        myLocation.iconImage = NMFOverlayImage(image: customIcon)
        myLocation.width = 64
        myLocation.height = 64
        myLocation.anchor = CGPoint(x: 0.5, y: 1.0)
        
        myLocation.mapView = mapView
        
        addSubview(mapView)
        addSubview(locationButton)
        
        tagScrollView.addSubview(tagStackView)
        addSubview(tagToggleButton)
        addSubview(tagScrollView)
        
        tagScrollView.isHidden = true
        
    }
    
    // MARK: - (F)Constraints
    private func setupConstraints() {
        // 지도 제약조건을 Auto Layout으로 설정하고 싶다면:
        mapView.translatesAutoresizingMaskIntoConstraints = false
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
            
            tagScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tagScrollView.leadingAnchor.constraint(equalTo: tagToggleButton.trailingAnchor, constant: 8),
            tagScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tagScrollView.bottomAnchor.constraint(equalTo: tagToggleButton.bottomAnchor),
            
            tagStackView.leadingAnchor.constraint(equalTo: tagScrollView.leadingAnchor),
            tagStackView.trailingAnchor.constraint(equalTo: tagScrollView.trailingAnchor),
            tagStackView.topAnchor.constraint(equalTo: tagScrollView.topAnchor),
            tagStackView.bottomAnchor.constraint(equalTo: tagScrollView.bottomAnchor),
            tagStackView.heightAnchor.constraint(equalTo: tagScrollView.heightAnchor)
            
        ])
    }

    func setTags(_ tags: [String]) {
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tag in tags {
            let tagButton = UIButton(type: .system)
            tagButton.setTitle(tag, for: .normal)
            tagButton.backgroundColor = .white
            tagButton.tintColor = .black
            tagButton.layer.cornerRadius = 8
            tagButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
            tagStackView.addArrangedSubview(tagButton)
        }
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
            

            
            if !hasFetchedPlaces {
                print("latitude: \(latitude_HVC), longitude: \(longitude_HVC)")
                hasFetchedPlaces = true
                fetchKakaoPlaces(keyword: "관광지",
                                 x: longitude_HVC,
                                 y: latitude_HVC,
                                 radius: 1500)
            }
        }
    }
}

// MARK: - Naver Local Search API
extension MapView {
    func fetchKakaoPlaces(keyword: String,
                            x lng: Double,
                            y lat: Double,
                            radius: Int = 1500,
                            page: Int = 1,
                            size: Int = 15) {
          // 간단 쿨타임
//          guard Date().timeIntervalSince(Self.lastKakaoCall) > kakaoCooldownSeconds else { return }
//          Self.lastKakaoCall = Date()

          var comp = URLComponents(string: "https://dapi.kakao.com/v2/local/search/keyword.json")
            comp?.queryItems = [
              .init(name: "query", value: keyword),
              .init(name: "x", value: String(lng)),       // 경도
              .init(name: "y", value: String(lat)),       // 위도
              .init(name: "radius", value: String(radius)), // 0~20000(m)
              .init(name: "page", value: String(page)),     // 1~45
              .init(name: "size", value: String(size))      // 1~15
            ]
            guard let url = comp?.url else { return }

          var req = URLRequest(url: url)
          req.httpMethod = "GET"
          req.setValue("KakaoAK d21a4bfef816e5e43a98ad54b649f54d", forHTTPHeaderField: "Authorization")

//        URLSession.shared.dataTask(with: req) { data, resp, err in
//            if let err = err { print("❌ 요청 에러:", err); return }
//
//            let http = resp as? HTTPURLResponse
//            print("🔎 status:", http?.statusCode ?? -1)
//
//            if let data = data, let body = String(data: data, encoding: .utf8) {
//                print("📩 body:", body)
//            } else {
//                print("📭 빈 바디 (data=nil)")
//                return
//            }
//            // ... (디코드 아래에서)
//        }.resume()
        
          URLSession.shared.dataTask(with: req) { data, resp, err in
              if let err = err { print("❌ Kakao 요청 에러:", err); return }
              guard let data = data else { print("❌ Kakao 데이터 없음"); return }

              // 디버그 원문 확인 원하면 주석 해제
              // print(String(data: data, encoding: .utf8) ?? "no body")

              do {
                  let result = try JSONDecoder().decode(KakaoSearchResponse.self, from: data)
                  DispatchQueue.main.async {
                      // 기존 마커 정리하고 싶으면 여기서 지우기
                      for place in result.documents {
                          guard let lng = Double(place.x), let lat = Double(place.y) else { continue }
                          let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: lng))
                          marker.captionText = place.place_name
                          marker.subCaptionText = place.category_name ?? ""
                          marker.touchHandler = { [weak self] _ in
                              print("📍 \(place.place_name) / \(place.road_address_name ?? place.address_name ?? "") / \(place.phone ?? "-")")
                              return true
                          }
                          marker.mapView = self.mapView
                      }
                  }
              } catch {
                  print("❌ Kakao JSON 파싱 실패:", error.localizedDescription)
              }
          }.resume()
    }
    
    // Kakao Local API 응답 모델
    struct KakaoSearchResponse: Codable {
        let documents: [KakaoPlace]
        let meta: KakaoMeta
    }

    struct KakaoMeta: Codable {
        let is_end: Bool
        let pageable_count: Int
        let total_count: Int
    }

    struct KakaoPlace: Codable {
        let id: String
        let place_name: String
        let category_name: String?
        let phone: String?
        let address_name: String?
        let road_address_name: String?
        let x: String   // 경도(LNG) 문자열
        let y: String   // 위도(LAT) 문자열
        let distance: String? // m 단위, 좌표 검색 시만
    }

}

