//
//  UserDefaultsManager.swift
//  PindoraShareExtension
//
//  Created by 김동현 on 7/19/25.
//

import Foundation

final class UserDefaultsManager {
    private static let sharedDefaults = UserDefaults(suiteName: "group.com.RETIA.pindora")
    
    enum Key: String {
        case sharedText
        case sharedURL
    }
    
    // MARK: - Save
    static func save(_ value: String, for key: Key) {
        sharedDefaults?.set(value, forKey: key.rawValue)
    }
    
    // MARK: - Get and Remove
    @discardableResult
    static func getAndRemove(for key: Key) -> String? {
        let value = sharedDefaults?.string(forKey: key.rawValue)
        sharedDefaults?.removeObject(forKey: key.rawValue)
        return value
    }
    
    // MARK: - Get only
    static func get(for key: Key) -> String? {
        return sharedDefaults?.string(forKey: key.rawValue)
    }
    
    // MARK: - Remove
    static func remove(for key: Key) {
        sharedDefaults?.removeObject(forKey: key.rawValue)
    }
}
