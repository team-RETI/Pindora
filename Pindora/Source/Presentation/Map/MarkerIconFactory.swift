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
    var sizeForShadow: CGFloat = 72
    var cornerRadius: CGFloat = 18   // 둥근 모서리
    var borderWidth: CGFloat = 1
    var borderColor: UIColor = .systemPink
    var isSelected: Bool = false
    var contentInset: CGFloat = 1    // 사진과 테두리 간격
}

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

enum MarkerIconFactory {
    
    /// 장소 마커 아이콘 제작
    /// - Parameters:
    ///   - image: 장소 이미지
    ///   - style: 마커 스타일 지정
    /// - Returns: 커스텀 마커
    static func makeIcon(from image: UIImage, style: MarkerStyle) -> NMFOverlayImage {
        let size = CGSize(width: style.size, height: style.size)
        let sizeForShadow = CGSize(width: style.sizeForShadow, height: style.sizeForShadow)
        // 바깥 래퍼(그림자용, 마스크 X)
        let wrapper = UIView(frame: CGRect(origin: .zero, size: sizeForShadow))
        wrapper.layer.shadowColor = UIColor.black.cgColor
        wrapper.layer.shadowOpacity = 0.25
        wrapper.layer.shadowOffset = CGSize(width: 0, height: 4)
        wrapper.layer.masksToBounds = false
        // 컨테이너(테두리 + 둥근 사각형)
        let container = UIView(frame: CGRect(origin: .zero, size: size))
        container.backgroundColor = .white
        container.layer.cornerRadius = style.cornerRadius
        container.layer.borderWidth = style.borderWidth
        container.layer.borderColor = style.borderColor.cgColor
        
        wrapper.addSubview(container)
        // 내부 이미지
        let imageView = UIImageView(frame: container.bounds)//.insetBy(dx: 6, dy: 6))//style.contentInset, dy: style.contentInset))
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        container.addSubview(imageView)
        
        if style.isSelected {
            let contentView = UIView(frame: container.bounds)
            contentView.backgroundColor = .black.withAlphaComponent(0.5)
            contentView.layer.cornerRadius = 18
            contentView.clipsToBounds = true
            container.addSubview(contentView)
            
            let magnifyIconSize: CGFloat = 30
            let magnifyIconView = UIImageView()
            magnifyIconView.frame = CGRect(
                x: (container.bounds.width - magnifyIconSize) / 2,
                y: (container.bounds.height - magnifyIconSize) / 2,
                width: magnifyIconSize,
                height: magnifyIconSize
            )
            magnifyIconView.image = UIImage(systemName: "magnifyingglass")
            magnifyIconView.contentMode = .scaleAspectFit
            magnifyIconView.tintColor = .white
            magnifyIconView.layer.cornerRadius = style.cornerRadius
            
            contentView.addSubview(magnifyIconView)
        }
        
        // 고해상도 렌더링
        let format = UIGraphicsImageRendererFormat()
        format.scale = 0                   // 화면 scale 자동
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: sizeForShadow, format: format)
        let uiImage = renderer.image { ctx in
            wrapper.layer.render(in: ctx.cgContext)
        }
        return NMFOverlayImage(image: uiImage)
    }

    /// 유저 마커 아이콘 제작
    /// - Parameter image: 유저 커스텀 이미지
    /// - Returns: 유저 커스텀 마커
    static func makeCustomUserIcon(from image: UIImage) -> UIImage {
        let size = CGSize(width: 64, height: 64)
        let sizeForShadow = CGSize(width: 70, height: 70)
        
        let wrapper = UIView(frame: CGRect(origin: .zero, size: sizeForShadow))
        wrapper.layer.shadowColor = UIColor.black.cgColor
        wrapper.layer.shadowOpacity = 0.25
        wrapper.layer.shadowOffset = CGSize(width: 0, height: 4)
        wrapper.layer.masksToBounds = false
        
        let container = UIView(frame: CGRect(origin: .zero, size: size))
        container.backgroundColor = .white
        container.layer.cornerRadius = 18
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.red.cgColor

        wrapper.addSubview(container)

        let imageView = UIImageView(frame: container.bounds.insetBy(dx: 6, dy: 6))
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18

        container.addSubview(imageView)

        // 고해상도 렌더링
        let format = UIGraphicsImageRendererFormat()
        format.scale = 0                   // 화면 scale 자동
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: sizeForShadow, format: format)
        return renderer.image { ctx in
            wrapper.layer.render(in: ctx.cgContext)
        }
    }
}
