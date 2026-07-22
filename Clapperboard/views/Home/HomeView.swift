//
//  HomeView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 09/11/2025.
//

import SwiftUI
import AppTrackingTransparency
import GoogleMobileAds

struct HomeView: View {
    
    @State private var viewModel = HomeViewModel()

    var body: some View {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 8) {
                        Text("Clapperboard")
                            .font(.largeTitle).bold()
                            .padding(.bottom, 2)
                        Text("Your personal film slate. Quickly set your default name and manage settings.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("How to use")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Create from a video in the app", systemImage: "video.badge.plus")
                        Label("Or use the Photo Extension from your library", systemImage: "photo.on.rectangle.angled")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                
                Section(header: Text("Clapperboard Preview")){
                    SlatePreviewView(name: viewModel.name, title: viewModel.title)
                }
//                .listRowInsets(EdgeInsets())
//                .listRowBackground(Color.clear)
                
            }
            .toolbar {
                
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .accessibilityLabel("More Settings")
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
