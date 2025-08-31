//
//  Date+.swift
//  Pindora
//
//  Created by eunchanKim on 8/31/25.
//

import Foundation

extension Date {
    /// 날짜를 원하는 형식의 문자열로 변환합니다.
    /// - Parameters:
    ///   - format: "yyyy-MM-dd", "yyyy.MM.dd HH:mm" 등
    ///   - locale: 로케일 (기본값: current)
    func toString(format: String = "yyyy-MM-dd", locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }
}
