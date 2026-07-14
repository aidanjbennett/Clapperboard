//
//  DescriptionView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 09/11/2025.
//

import SwiftUI

struct AboutDescriptionView: View {
    var body: some View {
        Section("About") {
            Text("Clapperboard helps you organize and interact with your photos seamlessly inside Apple Photos. Designed to feel right at home on iOS.")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.vertical, 4)
        }
    }
}

#Preview {
    AboutDescriptionView()
}
