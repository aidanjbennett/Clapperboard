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
                .safeAreaInset(edge: .bottom) {
                    CollapsibleAdBannerView(adUnitID: AdUnitID.homeBanner)
                        .frame(height: 60)
                        .background(.bar)
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }

                NavigationStack {
                    AddClapperboardView()
                }
                .safeAreaInset(edge: .bottom) {
                    CollapsibleAdBannerView(adUnitID: AdUnitID.homeBanner)
                        .frame(height: 60)
                        .background(.clear)
                }
                .tabItem {
                    Label("Add Clapperboard", systemImage: "video.badge.plus")
                }
            }
            .onAppear {
                Task {
                    if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                        let status = await ATTrackingManager.requestTrackingAuthorization()
                        print("Add tracking authorization: \(status)")
                    }
                }
            }
        }
}

#Preview {
    ContentView()
}

