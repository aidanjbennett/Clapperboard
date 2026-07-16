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
    
    @State private var viewModel = SettingsViewModel()
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
                
                Section(header: Text("Quick settings")) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .foregroundStyle(.secondary)
                        TextField("Default name", text: $viewModel.name)
                            .focused($nameIsFocused)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        viewModel.resetValues()
                    } label: {
                        Text("Reset to Defaults")
                    }
                }
                
                Section {
                    Text("Select videos in your library, then open Clapperboard to perform quick actions.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                }
                CollapsibleAdBannerView(
                    adUnitID: "ca-app-pub-7173006780619406/4564292462"
                )
                .frame(height: 60)
                
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        nameIsFocused = false
                        viewModel.save()
                    }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Text("More Settings")
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("More Settings")
                }
            }
            .navigationTitle("Home")
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
