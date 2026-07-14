//
//  UserDefaults.swift
//  ClapperboardCore
//
//  Created by Aidan Bennett on 14/07/2026.
//

import Foundation

@MainActor
extension UserDefaults {
    public static let shared = UserDefaults(suiteName: "group.com.aidanjbennett.clapperboard")!
    
    public enum Keys {
       public static let name = "name"
       public static let hasSeenOnboarding = "hasSeenOnboarding"
    }
}
