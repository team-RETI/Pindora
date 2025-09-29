//
//  UIImage+.swift
//  Pindora
//
//  Created by 장주진 on 9/29/25.
//

import UIKit

extension UIImage {
    /// 지정된 색상으로 정사각형 이미지를 생성
    static func fromColor(_ color: UIColor, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}
