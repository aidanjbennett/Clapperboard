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
    }
}

@Observable
class SettingsViewModel {

    var name: String = UserDefaults.shared.string(forKey: UserDefaults.Keys.name) ?? ""

    func save() {
        print("Saving settings")
        print("Name: \(name)")
        UserDefaults.shared.set(name, forKey: UserDefaults.Keys.name)
    }

    func resetValues() {
        print("Resetting settings")
        name = ""
        UserDefaults.shared.removeObject(forKey: UserDefaults.Keys.name)
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
