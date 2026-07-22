//
//  SettingsView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 15/07/2026.
//

import SwiftUI

struct SettingsView: View {

    @State private var viewModel = SettingsViewModel()
    @State private var showResetSettingsConfirmation = false
    
    var body: some View {
        Form {
            
            Section {
                HStack {
                    Image(systemName: "person.crop.circle")
                        .foregroundStyle(.secondary)
                    
                    TextField(
                        "Default Director name",
                        text: $viewModel.name
                    )
                }
                
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundStyle(.secondary)
                    
                    TextField(
                        "Default Title / Scene name",
                        text: $viewModel.title
                    )
                }
            } header: {
                Text("Slate Details")
            }
            
            
            Section {
                Toggle(
                    "Auto Increment Scene Number",
                    isOn: $viewModel.sceneAutoincrement
                )
                                
                Button(role: .destructive) {
                    viewModel.resetCurrentSceneNumber()
                    } label: {
                        Label(
                            "Reset Scene Count",
                            systemImage: "trash"
                        )
                    }
            } header: {
                Text("Scene Number")
            } footer: {
                Text("Automatically increases by one after each export.")
            }
            
            Section {
                Toggle(
                    "Auto Increment Take Number",
                    isOn: $viewModel.takeAutoincrement
                )
                
                Button(role: .destructive) {
                    viewModel.resetCurrentTakeNumber()
                } label: {
                    Label(
                        "Reset Take Count",
                        systemImage: "trash"
                    )
                }
            } header: {
                Text("Take Number")
            } footer: {
                Text("Automatically increases by one after each export.")
            }
            
            
            Section("Export") {
                
                Toggle(
                    "Save to Photos",
                    isOn: $viewModel.saveToPhotos
                )
                
            }
            Section {
                Picker(
                    "Theme",
                    selection: $viewModel.appearance
                ) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.rawValue)
                            .tag(mode)
                    }
                }
            } header: {
                Text("Appearance")
            }
            // TODO: Implement
//            Section("Premium") {
//
//                Button {
//                    // Purchase flow
//                    print("purchase flow")
//                } label: {
//                    Label(
//                        "Remove Ads",
//                        systemImage: "rectangle.slash"
//                    )
//                }
//
//                Button {
//                    // Restore purchases
//                    print("restore purchases")
//                } label: {
//                    Label(
//                        "Restore Purchases",
//                        systemImage: "arrow.clockwise"
//                    )
//                }
//            }

            Section {
                Link(
                    destination: URL(string: "https://apps.apple.com/app/id6759068299?action=write-review")!
                ) {
                    Label(
                        "Rate Clapperboard",
                        systemImage: "star"
                    )
                }

                Button {
                    viewModel.sendFeedback()
                } label: {
                    Label(
                        "Send Feedback",
                        systemImage: "envelope"
                    )
                }
            } header: {
                Text("Support")
            }


            Section {
                LabeledContent(
                    "Version",
                    value: "\(viewModel.appVersion) (\(viewModel.buildNumber))"
                )
                
                Link(
                    destination: URL(string: "https://aidanjbennett.com/clapperboard/privacy")!
                ) {
                    Label(
                        "Privacy Policy",
                        systemImage: "hand.raised"
                    )
                }

                Link(
                    destination: URL(string: "https://aidanjbennett.com/clapperboard/terms")!
                ) {
                    Label(
                        "Terms of Use",
                        systemImage: "doc.text"
                    )
                }
            } header: {
                Text("About")
            }


            Section {

                Button(role: .destructive) {
                    viewModel.resetValues()
                } label: {
                    Label(
                        "Reset Settings",
                        systemImage: "trash"
                    )
                }.confirmationDialog(
                    "Reset all settings to their defaults?",
                    isPresented: $showResetSettingsConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Reset", role: .destructive) {
                        viewModel.resetValues()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    NavigationStack {
        SettingsView()
    }
}
