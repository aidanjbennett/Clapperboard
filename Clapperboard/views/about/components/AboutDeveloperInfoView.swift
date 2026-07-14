//
//  DeveloperInfoView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 09/11/2025.
//

import SwiftUI

struct AboutDeveloperInfoView: View {
    var body: some View {
        Section("Developer") {
            Label("Aidan Bennett", systemImage: "person")
            Link(destination: URL(string: "https://aidanjbennett.com")!) {
                Label("Website", systemImage: "link")
            }
        }    }
}

#Preview {
    AboutDeveloperInfoView()
}
