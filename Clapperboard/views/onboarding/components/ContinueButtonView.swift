//
//  ContinueButtonView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 25/05/2026.
//

import SwiftUI

struct OnboardingContinueButtonView: View {

    let page: Int
    let pages: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(page == pages - 1 ? "Get Started" : "Continue")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primary)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    VStack(spacing: 20) {

        OnboardingContinueButtonView(
            page: 0,
            pages: 4
        ) {

        }

        OnboardingContinueButtonView(
            page: 3,
            pages: 4
        ) {

        }
    }
}
