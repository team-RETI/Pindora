//  MapViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import CoreLocation

final class MapViewModel: NSObject, CLLocationManagerDelegate {
    
    /// CLLocationManager 인스턴스 - 위치 추적을 담당하는 시스템 클래스
    private let locationManager = CLLocationManager()
    
    /// 권한 거부 콜백 알람
    var onPermissionDenied: (() -> Void)?
    
    /// 현재 위치를 외부에 전달하는 클로저
    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?
    
    override init() {
        super.init()
        configureLocationManager()
    }
    
    // MARK: - 앱 처음 켰을 때 권한 있는지 확인 및 요청
    /// 위치 서비스를 설정하고 시작하는 메서드입니다.
    /// 위치 권한을 요청하고, 위치 업데이트를 시작합니다.
    private func configureLocationManager() {
        locationManager.delegate = self // 델리게이트 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 가장 정확한 위치로 설정
        
        // 현재 권한 상태에 따라 분기 처리
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()         // 위치 업데이트 시작
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization() // 위치 권한 요청 (앱 사용 중)
        case .denied, .restricted:
            print("❌ 위치 권한 없음 또는 제한됨")
            
            DispatchQueue.main.async {
                self.onPermissionDenied?()
            }
        @unknown default:
            break
        }
    }
    
    // MARK: - 나중에 설정에서 권한 허용 및 위치 다시 시작
    /// 시스템이 자동 호출하는 델리게이트 메서드
    /// 사용자가 "설정 앱에서 위치 권한을 바꿨을 때도 호출됨"
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 뒤늦게라도 허용되면 → 위치 추적 시작
            manager.startUpdatingLocation()
        case .denied:
            print("❌ 거부됨")
        default:
            break
        }
    }
    
    /// 위치가 업데이트되었을 때 호출되는 델리게이트 메서드입니다.
    /// 마지막 위치 정보를 외부에 전달합니다.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        onLocationUpdate?(coordinate)
    }
    
    /// 위치 요청이 실패했을 때 호출되는 메서드입니다.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 가져오기 실패:", error.localizedDescription)
    }
    
}


