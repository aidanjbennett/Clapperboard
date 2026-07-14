//
//  OnboardingProgressDotsView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 25/05/2026.
//

import SwiftUI

struct OnboardingProgressDotsView: View {

    let page: Int
    let pages: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages, id: \.self) { index in
                Circle()
                    .fill(
                        page == index
                        ? Color.primary
                        : Color.secondary.opacity(0.3)
                    )
                    .frame(
                        width: page == index ? 10 : 7,
                        height: page == index ? 10 : 7
                    )
                    .scaleEffect(page == index ? 1.15 : 1.0)
                    .animation(
                        .spring(
                            response: 0.35,
                            dampingFraction: 0.75
                        ),
                        value: page
                    )
            }
        }
        .padding(.top, 10)
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingProgressDotsView(page: 0, pages: 4)
        OnboardingProgressDotsView(page: 1, pages: 4)
        OnboardingProgressDotsView(page: 2, pages: 4)
        OnboardingProgressDotsView(page: 3, pages: 4)
    }
    .padding()
}
