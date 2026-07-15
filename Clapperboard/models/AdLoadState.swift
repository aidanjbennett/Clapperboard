//
//  AdLoadState.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 15/07/2026.
//

import Foundation

enum AdLoadState {
    case pending
    case loaded
    case failed
}

extension AdLoadState: Equatable {}
