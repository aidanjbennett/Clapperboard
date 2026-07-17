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
        // Legacy
        public static let name = "name"
        
        // New stuff
        public static let appearanceMode = "appearanceMode"
        public static let title = "sceneTitle"

// TODO: Implement below
//        public static let sceneAutoincrement = "sceneAutoincrement"
//        public static let currentSceneNumber = "currentSceneNumber"
//        
//        public static let saveToPhotos = "saveToPhotos"
//        public static let keepOriginalAudio = "keepOriginalAudio"
//        public static let exportQuality = "exportQuality"
        
        // Onboarding
        public static let hasSeenOnboarding = "hasSeenOnboarding"
    }
}
