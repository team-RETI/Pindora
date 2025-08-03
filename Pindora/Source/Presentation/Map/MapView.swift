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
    
//    private var mapView: NMFMapView
    // MARK: - UI Component
    var mapView = NMFMapView()
    private let marker = NMFMarker()
//    let locationManager = CLLocationManager()
    
    let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - (F)UI Setup
    private func setupUI() {
        mapView = NMFMapView(frame: frame)
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.5665, lng: 126.9780)) // 서울
        mapView.moveCamera(cameraUpdate)
        
        marker.position = NMGLatLng(lat: 37.5665, lng: 126.9780)
        marker.mapView = mapView
        
//        locationManager.requestWhenInUseAuthorization()
        
        addSubview(mapView)
        addSubview(locationButton)

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
            locationButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

