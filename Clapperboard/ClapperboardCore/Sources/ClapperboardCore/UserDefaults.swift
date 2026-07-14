//
//  UserDefaults.swift
//  ClapperboardCore
//
//  Created by Aidan Bennett on 14/07/2026.
//

import Foundation

public extension UserDefaults {
    static var appGroup: UserDefaults {
        UserDefaults(suiteName: "group.com.aidanjbennett.clapperboard")!
    }

    enum Keys {
        public static let name = "name"
        public static let hasSeenOnboarding = "hasSeenOnboarding"
    }
}
