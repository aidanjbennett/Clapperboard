//
//  AdUnitID.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 16/07/2026.
//

import Foundation

enum AdUnitID {
    
    private static let testBanner = "ca-app-pub-3940256099942544/2934735716"
    
    static var homeBanner: String {
        #if DEBUG
        return testBanner
        #else
        return "ca-app-pub-7173006780619406/4564292462"
        #endif
    }

    static var addClapperboardBanner: String {
        #if DEBUG
        return testBanner
        #else
        return "ca-app-pub-7173006780619406/2346956143"
        #endif
    }
}
