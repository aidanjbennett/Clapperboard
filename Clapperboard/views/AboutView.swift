//
//  AboutView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 09/11/2025.
//

import SwiftUI

struct AboutView: View {
    
    var body: some View {
        NavigationStack {
            List {
                AboutHeaderView()
                AboutDeveloperInfoView()
                AboutDescriptionView()
            }
            .navigationTitle("About")
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
