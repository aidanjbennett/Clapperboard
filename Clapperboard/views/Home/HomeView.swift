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
    @State private var showResetConfirmation = false

    @FocusState private var nameIsFocused: Bool

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
                
                Section(header: Text("Quick settings"),
                        footer: Text("This name appears on every clapperboard slate you create.")) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .foregroundStyle(.secondary)
                        TextField("Default name", text: $viewModel.name)
                            .focused($nameIsFocused)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Text("Reset to Defaults")
                    }
                    .confirmationDialog(
                        "Reset your default name?",
                        isPresented: $showResetConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Reset", role: .destructive) {
                            viewModel.resetQuickSettings()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Create from a video in the app", systemImage: "video.badge.plus")
                        Label("Or use the Photo Extension from your library", systemImage: "photo.on.rectangle.angled")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                
                Section {
                    CollapsibleAdBannerView(
                        adUnitID: AdUnitID.homeBanner
                    )
                    .frame(height: 60)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
            }
            .toolbar {
                
                ToolbarItem(placement: .keyboard) {
                      Spacer()
                  }
                
                ToolbarItem(placement: .keyboard) {
                      Button("Done") {
                          nameIsFocused = false
                      }
                  }
              
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
