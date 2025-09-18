//
//  NaverMap+.swift
//  Pindora
//
//  Created by eunchanKim on 9/6/25.
//

import Foundation
import NMapsMap
import CoreLocation

extension NMGLatLng {
    // NMGLatLng -> CLLocationCoordinate2D 변환
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
    }
}
