//
//  ClapperboardConfiguration.swift
//  PhotoExtension
//
//  Created by Aidan Bennett on 13/05/2026.
//

import Foundation
import ClapperboardCore

struct ClapperboardConfiguration {
    
    var title: String
    var scene: String
    var take: String
    var director: String
    var selectedDate: Date = Date()

    var date: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: selectedDate)
    }
    
    // Default
    static var `default`: ClapperboardConfiguration {
        let storedName = UserDefaults.shared.string(
            forKey: UserDefaults.Keys.name
        ) ?? "John Doe"

        return ClapperboardConfiguration(
            title: "My Scene",
            scene: "1",
            take: "1",
            director: storedName,
            selectedDate: Date()
        )
    }

    func toAdjustmentDataPayload() throws -> Data {
        try JSONSerialization.data(withJSONObject: [
            "title": title,
            "scene": scene,
            "take": take,
            "director": director,
            "date": date,
            "selectedDate": selectedDate.timeIntervalSince1970
        ])
    }
}
