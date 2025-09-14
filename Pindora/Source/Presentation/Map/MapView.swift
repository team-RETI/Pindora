//  MapViewView.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import NMapsMap
import CoreLocation
import Combine

// MARK: - (C)MapView
final class MapView: UIView {
    
    // MARK: - UI Component
    var mapView = NMFMapView()
    let categoryListView = CategoryCellListView()
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
}
