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
                
                                Toggle(
                                    "Auto Increment Scene Number",
                                    isOn: $viewModel.sceneAutoincrement
                                )
                                
                                Button {
                                    viewModel.resetCurrentSceneNumber()
                                } label: {
                                    Label(
                                        "Reset Scene Count",
                                        systemImage: "trash"
                                    )
                                }
                
                
            }
            
            
//            Section("Export") {
//                
//                Toggle(
//                    "Save to Photos",
//                    isOn: $viewModel.saveToPhotos
//                )
//                
//            }
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


            Section("Support") {

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

//                Button {
//                    // Feature request
//                } label: {
//                    Label(
//                        "Request Feature",
//                        systemImage: "lightbulb"
//                    )
//                }
            }


            Section("About") {

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
