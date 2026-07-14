//
//  AddClapperboardView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 14/07/2026.
//

import SwiftUI

struct AddClapperboardView: View {

    var body: some View {
        VStack(spacing: 24) {
            Text("Add Clapperboard")
                .font(.largeTitle)
        }
        .padding()
        .navigationTitle("Add Clapperboard")
    }
}

#Preview {
    NavigationStack {
        AddClapperboardView()
    }
}
