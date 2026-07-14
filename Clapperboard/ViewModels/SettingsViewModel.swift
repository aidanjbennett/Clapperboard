//
//  SettingsViewModel.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 09/11/2025.
//

import Foundation
import ClapperboardCore

@Observable
class SettingsViewModel {

    var name: String = UserDefaults.appGroup.string(
        forKey: UserDefaults.Keys.name
    ) ?? ""

    func save() {
        UserDefaults.appGroup.set(name, forKey: UserDefaults.Keys.name)
    }

    func resetValues() {
        name = ""
        UserDefaults.appGroup.removeObject(forKey: UserDefaults.Keys.name)

        #if DEBUG
        UserDefaults.standard.removeObject(
            forKey: UserDefaults.Keys.hasSeenOnboarding
        )
        #endif // DEBUG
    }

    func setName(_ name: String) {
        guard !name.isEmpty else { return }
        self.name = name
        save()
    }
}
