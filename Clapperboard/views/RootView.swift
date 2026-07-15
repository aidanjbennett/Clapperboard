//
//  RootView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 25/05/2026.
//

import SwiftUI
import Sentry
import ClapperboardCore

struct RootView: View {
    @AppStorage(
        UserDefaults.Keys.hasSeenOnboarding,
        store: UserDefaults.appGroup
    )
    private var hasSeenOnboarding = false

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
