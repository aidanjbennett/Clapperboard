//
//  SettingsViewModel.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 09/11/2025.
//

import Foundation
import ClapperboardCore
import UIKit

@Observable
final class SettingsViewModel {
    
    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
    
    var name: String = Foundation.UserDefaults.appGroup.string(
        forKey: Foundation.UserDefaults.Keys.name
    ) ?? ""

    var title: String = Foundation.UserDefaults.appGroup.string(
        forKey: Foundation.UserDefaults.Keys.title
    ) ?? ""

    var sceneAutoincrement: Bool = Foundation.UserDefaults.appGroup.bool(
        forKey: Foundation.UserDefaults.Keys.sceneAutoincrement
    )
    
    var currentSceneNumber: Int = Foundation.UserDefaults.appGroup.integer(
        forKey: Foundation.UserDefaults.Keys.currentSceneNumber
    )
    
    var appearance: AppearanceMode {
         didSet {
             Foundation.UserDefaults.appGroup.set(appearance.rawValue, forKey: Foundation.UserDefaults.Keys.appearanceMode)
         }
     }

//    var saveToPhotos: Bool = Foundation.UserDefaults.appGroup.object(
//        forKey: Foundation.UserDefaults.Keys.saveToPhotos
//    ) as? Bool ?? true

    init() {
        let storedAppearanceMode = Foundation.UserDefaults.appGroup.string(forKey: Foundation.UserDefaults.Keys.appearanceMode) ?? AppearanceMode.system.rawValue
           appearance = AppearanceMode(rawValue: storedAppearanceMode) ?? .system
    }
    
    func save() {
        Foundation.UserDefaults.appGroup.set(
            name,
            forKey: Foundation.UserDefaults.Keys.name
        )
        
        Foundation.UserDefaults.appGroup.set(
            appearance.rawValue,
            forKey: Foundation.UserDefaults.Keys.appearanceMode
        )
        
        Foundation.UserDefaults.appGroup.set(
            title,
            forKey: Foundation.UserDefaults.Keys.title
        )
        
        Foundation.UserDefaults.appGroup.set(
            sceneAutoincrement,
            forKey: Foundation.UserDefaults.Keys.sceneAutoincrement
        )
        
        Foundation.UserDefaults.appGroup.set(
            1,
            forKey: Foundation.UserDefaults.Keys.currentSceneNumber
        )
        

//        Foundation.UserDefaults.appGroup.set(
//            saveToPhotos,
//            forKey: Foundation.UserDefaults.Keys.saveToPhotos
//        )
    }
    
    func sendFeedback() {
        let subject = "Clapperboard Feedback"
        let body = """



        ---
        App Version: \(appVersion)
        Build: \(buildNumber)
        iOS: \(UIDevice.current.systemVersion)
        Device: \(UIDevice.current.model)
        """

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "aidanbennett3@icloud.com"
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]

        guard let url = components.url else { return }

        UIApplication.shared.open(url)
    }
    
    func resetCurrentSceneNumber() {
        currentSceneNumber = 1
      
        Foundation.UserDefaults.appGroup.set(
            currentSceneNumber,
            forKey: Foundation.UserDefaults.Keys.currentSceneNumber
        )
    }

    func resetValues() {
        name = ""
        title = ""
        
        sceneAutoincrement = false
        currentSceneNumber = 1
        // saveToPhotos = true
        
        appearance = .system
        
        Foundation.UserDefaults.appGroup.removeObject(forKey: Foundation.UserDefaults.Keys.appearanceMode)

        Foundation.UserDefaults.appGroup.removeObject(forKey: Foundation.UserDefaults.Keys.name)
        
        Foundation.UserDefaults.appGroup.removeObject(forKey: Foundation.UserDefaults.Keys.title)

        Foundation.UserDefaults.appGroup.removeObject(forKey: Foundation.UserDefaults.Keys.sceneAutoincrement)
        
        Foundation.UserDefaults.appGroup.removeObject(forKey: Foundation.UserDefaults.Keys.currentSceneNumber)
        
        // Foundation.UserDefaults.appGroup.removeObject(forKey: Foundation.UserDefaults.Keys.saveToPhotos)
        
        // Remove old not used onboarding object
        Foundation.UserDefaults.appGroup.removeObject( forKey: Foundation.UserDefaults.Keys.hasSeenOnboarding)
    }

    func setName(_ name: String) {
        guard !name.isEmpty else { return }

        self.name = name

        Foundation.UserDefaults.appGroup.set(
            name,
            forKey: Foundation.UserDefaults.Keys.name
        )
    }
}

