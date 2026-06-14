//
//  RootView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 25/05/2026.
//

import SwiftUI
import Sentry

struct RootView: View {
    // Get from user defaults
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
          Group {
              if hasSeenOnboarding {
                  ContentView()
              } else {
                  OnboardingView()
              }
          }
          .onAppear {
              // Test sentry error
              #if DEBUG
              let error = NSError(
                     domain: "Clapperboard",
                     code: 999,
                     userInfo: [NSLocalizedDescriptionKey: "Sentry test error"]
                 )

              SentrySDK.capture(error: error)
              #endif
          }
    }
}

#Preview {
    RootView()
}
