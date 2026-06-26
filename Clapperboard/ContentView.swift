//
//  ContentView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 15/10/2025.
//

import SwiftUI
import AppTrackingTransparency

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                AboutView()
            }
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }.onAppear {
            Task {
                if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                    let status = await ATTrackingManager.requestTrackingAuthorization()
                                // optionally store/log status
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}

