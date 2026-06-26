//
//  AboutView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 09/11/2025.
//

import SwiftUI
import GoogleMobileAds

struct AboutView: View {
    
    var body: some View {
            List {
                AboutHeaderView()
                AboutDeveloperInfoView()
                AboutDescriptionView()
                BannerAdView(
                             adUnitID: "ca-app-pub-7173006780619406~1224612011",
                             adSize: largeAnchoredAdaptiveBanner(width: UIScreen.main.bounds.width)
                         )
                         .frame(height: 60)
            }
            .navigationTitle("About")
        }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
