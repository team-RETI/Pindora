//  MapViewController.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import MapKit

final class MapViewController: UIViewController {
    private let viewModel: MapViewModel
    private let customView = MapView()
    private var didAddRandomMarkers: Bool = false
    
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
        bindViewModel()
        
        customView.mapView.delegate = self
        customView.locationButton.addTarget(self, action: #selector(moveToMyLocation), for: .touchUpInside)
        randomMarker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("MapViewController")
        checkLocationPermission()
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
    
    }
    
    private func checkLocationPermission() {
        let status = CLLocationManager().authorizationStatus
        if status == .denied || status == .restricted {
            // ❗️ViewModel 거치지 않고 직접 얼럿 띄움
            let alert = UIAlertController(
                title: "위치 권한이 필요합니다",
                message: "설정으로 이동하여 위치 권한을 허용해주세요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "설정 열기", style: .default, handler: { _ in
                if let url = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }))
            present(alert, animated: true)
        }
    }
    
    @objc private func moveToMyLocation() {
        customView.mapView.setUserTrackingMode(.follow, animated: true)
    }
}

// MARK: - 랜덤 마커
extension MapViewController: MKMapViewDelegate {
    
    func randomMarker() {
        viewModel.onLocationUpdate = { [weak self] coordinate in
            guard let self = self else { return }
            
            if !self.didAddRandomMarkers {
                 self.addRandomMarkers(near: coordinate)
                 self.didAddRandomMarkers = true
             }
            /*
            guard !self.didAddRandomMarkers else { return }
            self.didAddRandomMarkers(near: coordinate)
            self.didAddRandomMarkers = true
             */
        }
    }
    
    func addRandomMarkers(near coordinate: CLLocationCoordinate2D) {
        let mapView = customView.mapView
        
        for _ in 0..<3 {
            let randomLat = coordinate.latitude + Double.random(in: -0.002...0.002)
            let randomLong = coordinate.longitude + Double.random(in: -0.002...0.002)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: randomLat, longitude: randomLong)
            annotation.title = "랜덤 마커"
            mapView.addAnnotation(annotation)
        }
    }
    
    // 마커를 탭했을 때 호출되는 메서드
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinate = view.annotation?.coordinate else { return }

        let detailVC = MarkerDetailViewController(coordinate: coordinate)

        if let sheet = detailVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        present(detailVC, animated: true)
    }
}

 
#Preview {
    MapViewController(viewModel: MapViewModel())
}



import UIKit
import MapKit

final class MarkerDetailViewController: UIViewController {
    private let coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let locationLabel = UILabel()
        locationLabel.text = "📍 위치: \(coordinate.latitude), \(coordinate.longitude)"
        locationLabel.textAlignment = .center
        locationLabel.numberOfLines = 0

        let apiInfoLabel = UILabel()
        apiInfoLabel.text = """
        ℹ️ 이 앱은 인스타그램 oEmbed API를 사용하여 \
        사용자가 공유한 게시물의 미리보기 정보(작성자, 이미지, 본문 등)를 \
        앱 내부에서 표시합니다.
        """
        apiInfoLabel.textColor = .secondaryLabel
        apiInfoLabel.font = .systemFont(ofSize: 14)
        apiInfoLabel.numberOfLines = 0
        apiInfoLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [locationLabel, apiInfoLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
