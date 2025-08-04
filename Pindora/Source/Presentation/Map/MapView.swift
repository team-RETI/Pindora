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
    private var selectableMarker: SelectableMarker?
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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - (F)UI Setup
    private func setupUI() {
                
        addSubview(mapView)
        addSubview(locationButton)
        
        tagScrollView.addSubview(tagStackView)
        addSubview(tagToggleButton)
        addSubview(tagScrollView)
        
        tagScrollView.isHidden = true
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        mapView.frame = bounds

        let center = NMGLatLng(lat: 37.579617, lng: 126.977041)
        mapView.moveCamera(NMFCameraUpdate(scrollTo: center))
        
        let photo = UIImage(named: "경복궁") ?? UIImage()
        selectableMarker = SelectableMarker(position: center, image: photo)
        selectableMarker?.attach(to: mapView)
        
       
        
        selectableMarker?.marker.touchHandler = { [weak self] _ in
            guard let self = self else { return false }
            
            // 🔁 토글 로직
            self.isMarkerSelected.toggle()
            self.selectableMarker?.setSelected(self.isMarkerSelected)
            
            return true  // ✅ 여기서 true로 반환해서 배경 탭으로 전달되지 않도록
        }
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
