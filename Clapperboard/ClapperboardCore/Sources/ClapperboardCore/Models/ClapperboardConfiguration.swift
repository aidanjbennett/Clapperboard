//
//  ClapperboardConfiguration.swift
//  ClapperboardCore
//
//  Created by Aidan Bennett on 13/05/2026.
//

import Foundation

public struct ClapperboardConfiguration : Equatable {
    
    public var title: String
    public var scene: String
    public var take: String
    public var director: String
    public var selectedDate: Date = Date()

    public var date: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: selectedDate)
    }
    
    // Default
    public static var `default`: ClapperboardConfiguration {
        
        let storedName = UserDefaults.appGroup.string(
            forKey: UserDefaults.Keys.name
        ) ?? "John Doe"
        
        let storedSceneTitle = UserDefaults.appGroup.string(
            forKey: UserDefaults.Keys.title
        ) ?? "My Scene"
        
        var storedSceneNumber = UserDefaults.appGroup.integer(
            forKey: UserDefaults.Keys.currentSceneNumber
        )
        
        var storedTakeNumber = UserDefaults.appGroup.integer(
            forKey: UserDefaults.Keys.currentTakeNumber
        )
        
        if (storedTakeNumber == 0) {
            UserDefaults.appGroup.set(1, forKey: UserDefaults.Keys.currentTakeNumber)
            storedTakeNumber = 1
        }
        
        if (storedSceneNumber == 0) {
            UserDefaults.appGroup.set(1, forKey: UserDefaults.Keys.currentSceneNumber)
            storedSceneNumber += 1
        }
        
        return ClapperboardConfiguration(
                title: storedSceneTitle,
                scene: "\(storedSceneNumber)",
                take: "\(storedTakeNumber)",
                director: storedName,
                selectedDate: .now
        )
    }

     public func toAdjustmentDataPayload() throws -> Data {
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

