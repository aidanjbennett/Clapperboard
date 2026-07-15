//
//  SettingsView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 15/07/2026.
//

import SwiftUI

struct SettingsView: View {

    @State private var viewModel = SettingsViewModel()

    var body: some View {
        Form {

            Section("Clapperboard Defaults") {

                TextField(
                    "Director",
                    text: $viewModel.name
                )

                TextField(
                    "Scene",
                    text: $viewModel.scene
                )
            }


            Section("Export") {

                Toggle(
                    "Save to Photos",
                    isOn: $viewModel.saveToPhotos
                )

//                Picker(
//                    "Quality",
//                    selection: $viewModel.exportQuality
//                ) {
//                    ForEach(ExportQuality.allCases) { quality in
//                        Text(quality.rawValue)
//                            .tag(quality)
//                    }
//                }
            }


            Section("Appearance") {

                Picker(
                    "Theme",
                    selection: $viewModel.appearance
                ) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.rawValue)
                            .tag(mode)
                    }
                }
            }


            Section("Premium") {

                Button {
                    // Purchase flow
                } label: {
                    Label(
                        "Remove Ads",
                        systemImage: "rectangle.slash"
                    )
                }

                Button {
                    // Restore purchases
                } label: {
                    Label(
                        "Restore Purchases",
                        systemImage: "arrow.clockwise"
                    )
                }
            }


            Section("Support") {

                Button {
                    // Open App Store review
                } label: {
                    Label(
                        "Rate Clapperboard",
                        systemImage: "star"
                    )
                }

                Button {
                    // Open feedback email
                } label: {
                    Label(
                        "Send Feedback",
                        systemImage: "envelope"
                    )
                }

                Button {
                    // Feature request
                } label: {
                    Label(
                        "Request Feature",
                        systemImage: "lightbulb"
                    )
                }
            }


            Section("About") {

                LabeledContent(
                    "Version",
                    value: "1.0" // TODO: Fetch from the view model
                )

                Link(
                    destination: URL(string: "https://aidanjbennett.com/clapperboard/privacy")!
                ) {
                    Label(
                        "Privacy Policy",
                        systemImage: "hand.raised"
                    )
                }

//                Link(
//                    destination: URL(string: "https://yourwebsite.com/terms")!
//                ) {
//                    Label(
//                        "Terms of Use",
//                        systemImage: "doc.text"
//                    )
//                }
            }


            Section {

                Button(role: .destructive) {
                    viewModel.resetValues()
                } label: {
                    Label(
                        "Reset Settings",
                        systemImage: "trash"
                    )
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.save()
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        SettingsView()
    }
}
