//
//  RootView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 25/05/2026.
//

import SwiftUI

struct RootView: View {
    // Get from user defaults
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if hasSeenOnboarding {
            ContentView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    RootView()
}
