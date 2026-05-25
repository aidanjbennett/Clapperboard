//
//  WelcomePageView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 25/05/2026.
//

import SwiftUI

struct WelcomePageView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "film")
                .font(.system(size: 70))
                .symbolRenderingMode(.hierarchical)

            Text("Welcome to Clapperboard")
                .font(.title)
                .bold()

            Text("Add a clapperboard overlay to your videos directly inside Photos.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    WelcomePageView()
}
