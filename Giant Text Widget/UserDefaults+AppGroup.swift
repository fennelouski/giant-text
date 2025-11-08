//
//  UserDefaults+AppGroup.swift
//  Giant Text
//
//  Extension for shared app group UserDefaults
//  Allows main app and widget to share settings
//

import Foundation

extension UserDefaults {
    static let appGroup = UserDefaults(suiteName: "group.com.fennel.Giant-Text") ?? .standard
}
