//
//  MarkerIconFactory.swift
//  Pindora
//
//  Created by eunchanKim on 8/5/25.
//

import UIKit
import NMapsMap

struct MarkerStyle {
    var size: CGFloat = 64           // 전체 아이콘 크기
    var cornerRadius: CGFloat = 18   // 둥근 모서리
    var borderWidth: CGFloat = 3
    var borderColor: UIColor = .systemPink
    var addShadow: Bool = true
    var contentInset: CGFloat = 6    // 사진과 테두리 간격
}

final class SelectableMarker {
    let marker = NMFMarker()
    private let normalIcon: NMFOverlayImage
    private let selectedIcon: NMFOverlayImage
  
    init(position: NMGLatLng, image: UIImage) {
        let normal = MarkerStyle(size: 64, cornerRadius: 18, borderWidth: 2, borderColor: .lightGray, addShadow: true, contentInset: 6)
        let selected = MarkerStyle(size: 72, cornerRadius: 20, borderWidth: 3, borderColor: .systemPink, addShadow: true, contentInset: 6)
        
        self.normalIcon = MarkerIconFactory.makeIcon(from: image, style: normal)
        self.selectedIcon = MarkerIconFactory.makeIcon(from: image, style: selected)

        marker.position = position
        marker.iconImage = normalIcon
        marker.iconTintColor = .clear
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
    }

    func attach(to mapView: NMFMapView) { marker.mapView = mapView }
    func setSelected(_ isSelected: Bool) {
        marker.iconImage = isSelected ? selectedIcon : normalIcon
        marker.zIndex = isSelected ? 1000 : 0
    }
}

enum MarkerIconFactory {
    static func makeIcon(from image: UIImage, style: MarkerStyle) -> NMFOverlayImage {
        let size = CGSize(width: style.size, height: style.size)

        // 바깥 래퍼(그림자용, 마스크 X)
        let wrapper = UIView(frame: CGRect(origin: .zero, size: size))
        wrapper.backgroundColor = .clear
        if style.addShadow {
            wrapper.layer.shadowColor = UIColor.black.cgColor
            wrapper.layer.shadowOpacity = 0.25
            wrapper.layer.shadowRadius = 8
            wrapper.layer.shadowOffset = CGSize(width: 0, height: 4)
        }

        // 컨테이너(테두리 + 둥근 사각형)
        let container = UIView(frame: wrapper.bounds)
        container.backgroundColor = .white
        container.layer.cornerRadius = style.cornerRadius
        container.layer.borderWidth = style.borderWidth
        container.layer.borderColor = style.borderColor.cgColor
        container.layer.masksToBounds = true
        wrapper.addSubview(container)

        // 내부 이미지
        let imageView = UIImageView(frame: container.bounds.insetBy(dx: style.contentInset, dy: style.contentInset))
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = max(0, style.cornerRadius - style.contentInset)
        imageView.layer.masksToBounds = true
        container.addSubview(imageView)

        // 고해상도 렌더링
        let format = UIGraphicsImageRendererFormat()
        format.scale = 0                   // 화면 scale 자동
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let uiImage = renderer.image { ctx in
            wrapper.layer.render(in: ctx.cgContext)
        }
        return NMFOverlayImage(image: uiImage)
    }
}
