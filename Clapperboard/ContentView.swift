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
                AddClapperboardView()
            }.tabItem {
                Label("Add Clapperboard", systemImage: "video.badge.plus")
            }
            
        }.onAppear {
            Task {
                if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                    let status = await ATTrackingManager.requestTrackingAuthorization()
                    // optionally store/log status
                    print("Add tracking authorization: \(status)")
                    
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}

