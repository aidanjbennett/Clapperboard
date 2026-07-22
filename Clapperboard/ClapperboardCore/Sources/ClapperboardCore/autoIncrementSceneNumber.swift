//
//  autoIncrementSceneNumber.swift
//  ClapperboardCore
//
//  Created by Aidan Bennett on 17/07/2026.
//

import Foundation

public func autoIncrementSceneNumber() {
    
    var storedSceneNumber = UserDefaults.appGroup.integer(
        forKey: UserDefaults.Keys.currentSceneNumber
    )
    
    storedSceneNumber += 1
    
    UserDefaults.appGroup.set(
        storedSceneNumber,
        forKey: UserDefaults.Keys.currentSceneNumber
    )
}

public func autoIncrementTakeNumber() {
    
    var storedTakeNumber = UserDefaults.appGroup.integer(
        forKey: UserDefaults.Keys.currentTakeNumber
    )
    
    storedTakeNumber += 1
    
    UserDefaults.appGroup.set(
        storedTakeNumber,
        forKey: UserDefaults.Keys.currentTakeNumber
    )
}
