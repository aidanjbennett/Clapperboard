//
//  OnboardingModel.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 25/05/2026.
//

import Foundation

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
}
