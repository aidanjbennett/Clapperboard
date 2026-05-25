//
//  OnboardingView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 25/05/2026.
//

import SwiftUI

struct OnboardingView: View {

    
    @State private var page = 0
    @State private var nameInput = ""
    @State private var settingsVM = SettingsViewModel()

    private let pages = 4

    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Spacer()
                Button("Skip") {
                    finish()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding()
            }

            TabView(selection: $page) {

                WelcomePageView()
                    .tag(0)

                FeaturePageView()
                    .tag(1)

                PreviewPageView()
                    .tag(2)

                SetupPageView(nameInput: $nameInput)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            OnboardingProgressDotsView(page: page, pages: pages)
            
            OnboardingContinueButtonView(page: page, pages: pages) {
                if page == pages - 1 {
                    finish()
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        page += 1
                    }
                }
            }
        }
        
        .onAppear {
            nameInput = settingsVM.name
        }
    }

    private func finish() {
        settingsVM.setName(nameInput)
        
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }
}

#Preview {
    OnboardingView()
}
