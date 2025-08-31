//
//  String+.swift
//  Pindora
//
//  Created by eunchanKim on 8/31/25.
//

import Foundation

extension String {
    func toDate(format: String = "yyyy-MM-dd", locale: Locale = .current) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.date(from: self)
    }
}
