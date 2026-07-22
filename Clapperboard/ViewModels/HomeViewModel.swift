//
//  HomeViewModel.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 22/07/2026.
//

import Foundation
import ClapperboardCore

@Observable
final class HomeViewModel {
    
    var name: String {
        didSet {
            Foundation.UserDefaults.appGroup.set(name, forKey: Foundation.UserDefaults.Keys.name)
        }
    }
    
    var title: String {
        didSet {
            Foundation.UserDefaults.appGroup.set(title, forKey: Foundation.UserDefaults.Keys.title)
        }
    }
    
    init() {
        name  = Foundation.UserDefaults.appGroup.string(forKey: Foundation.UserDefaults.Keys.name) ?? ""
        title = Foundation.UserDefaults.appGroup.string(forKey: Foundation.UserDefaults.Keys.title) ?? ""

    }
}
