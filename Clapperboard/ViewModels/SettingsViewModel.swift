//
//  SettingsViewModel.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 09/11/2025.
//

import Foundation
import ClapperboardCore

@Observable
final class SettingsViewModel {
    
    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
    
    var name: String = UserDefaults.appGroup.string(
        forKey: UserDefaults.Keys.name
    ) ?? ""

    var title: String = UserDefaults.appGroup.string(
        forKey: UserDefaults.Keys.title
    ) ?? ""

    var scene: String = UserDefaults.appGroup.string(
        forKey: UserDefaults.Keys.scene
    ) ?? ""
    
    var appearance: AppearanceMode = .system

    // MARK: - Export

    var saveToPhotos: Bool = UserDefaults.appGroup.object(
        forKey: UserDefaults.Keys.saveToPhotos
    ) as? Bool ?? true


    // MARK: - Persistence

    func save() {
        UserDefaults.appGroup.set(
            name,
            forKey: UserDefaults.Keys.name
        )

        UserDefaults.appGroup.set(
            title,
            forKey: UserDefaults.Keys.title
        )

        UserDefaults.appGroup.set(
            scene,
            forKey: UserDefaults.Keys.scene
        )

        UserDefaults.appGroup.set(
            saveToPhotos,
            forKey: UserDefaults.Keys.saveToPhotos
        )
    }


    func resetValues() {
        name = ""
        title = ""
        scene = ""
        saveToPhotos = true

        UserDefaults.appGroup.removeObject(
            forKey: UserDefaults.Keys.name
        )

        UserDefaults.appGroup.removeObject(
            forKey: UserDefaults.Keys.title
        )

        UserDefaults.appGroup.removeObject(
            forKey: UserDefaults.Keys.scene
        )

        UserDefaults.appGroup.removeObject(
            forKey: UserDefaults.Keys.saveToPhotos
        )

        #if DEBUG
        UserDefaults.appGroup.removeObject(
            forKey: UserDefaults.Keys.hasSeenOnboarding
        )
        #endif
    }

    func setName(_ name: String) {
        guard !name.isEmpty else { return }

        self.name = name

        UserDefaults.appGroup.set(
            name,
            forKey: UserDefaults.Keys.name
        )
        
        print("saved name: \(name)")
    }
}

enum ExportQuality: String, CaseIterable, Identifiable {
    case hd = "720p"
    case fullHD = "1080p"
    case ultraHD = "4K"

    var id: String { rawValue }
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }
}

