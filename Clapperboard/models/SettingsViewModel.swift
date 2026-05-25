//
//  SettingsViewModel.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 09/11/2025.
//
import Foundation

extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.com.aidanjbennett.clapperboard")!
    
    enum Keys {
        static let name = "name"
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }
}

@Observable
class SettingsViewModel {
    
    var name: String = UserDefaults.shared.string(forKey: UserDefaults.Keys.name) ?? ""
    
    func save() {
        UserDefaults.shared.set(name, forKey: UserDefaults.Keys.name)
    }
    
    func resetValues() {
        name = ""
        UserDefaults.shared.removeObject(forKey: UserDefaults.Keys.name)
        
        #if DEBUG
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.hasSeenOnboarding)
        #endif
    }
    
    func setName(_ name: String) {
        guard !name.isEmpty else {
            print("Name is empty")
            return
        }
        self.name = name
        save()
    }
    
}
