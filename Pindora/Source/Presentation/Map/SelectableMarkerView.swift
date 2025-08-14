//
//  SelectableMarkerView.swift
//  Pindora
//
//  Created by eunchanKim on 8/11/25.
//

import UIKit
import NMapsMap

final class SelectableMarker {
    let marker = NMFMarker()
    private let normalIcon: NMFOverlayImage
    private let selectedIcon: NMFOverlayImage
    
    init(position: NMGLatLng, image: UIImage) {
        let normal = MarkerStyle(size: 64, sizeForShadow: 70, cornerRadius: 18, borderWidth: 1, borderColor: .systemPink, isSelected: false, contentInset: 6)
        let selected = MarkerStyle(size: 64, sizeForShadow: 70, cornerRadius: 18, borderWidth: 1, borderColor: .systemPink, isSelected: true, contentInset: 6)
        
        self.normalIcon = MarkerIconFactory.makeIcon(from: image, style: normal)
        self.selectedIcon = MarkerIconFactory.makeIcon(from: image, style: selected)
        
        marker.position = position
        marker.iconImage = normalIcon
        marker.iconTintColor = .clear
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
    }
    
    func attach(to mapView: NMFMapView) { marker.mapView = mapView }
    func setSelected(_ isSelected: Bool) {
        let newIcon = isSelected ? selectedIcon : normalIcon
        if marker.iconImage !== newIcon {  // 렌더링 최적화
            marker.iconImage = newIcon
            marker.zIndex = isSelected ? 1000 : 0
        }
    }
}

