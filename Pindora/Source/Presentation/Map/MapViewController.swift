//  MapViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import NMapsMap
import CoreLocation

final class MapViewController: UIViewController, CLLocationManagerDelegate {
    private let viewModel: MapViewModel
    private let locationManager = CLLocationManager()
    private let customView = MapView()
    
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

    @objc private func locationButtonTapped() {
        customView.mapView.positionMode = .direction // 또는 .normal
    }
    
    private func requestLocationPermission() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}
