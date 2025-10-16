//
//  UIImageView+.swift
//  Pindora
//
//  Created by 장주진 on 10/11/25.
//

import UIKit

extension UIImageView {
    func setImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self.image = UIImage(named: "default_memoji")
                }
            }
        }
    }
}
