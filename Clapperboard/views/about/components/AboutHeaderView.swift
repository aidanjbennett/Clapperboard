//
//  AboutHeaderView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 09/11/2025.
//

import SwiftUI

struct AboutHeaderView: View {
    
    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ??
        "Clapperboard"
    }
    
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    
    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
    
    var body: some View {
        Section {
            VStack(spacing: 8) {
                Image(systemName: "film.stack")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                    .padding(.top, 8)
                
                Text(appName)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Version \(appVersion) (\(buildNumber))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .listRowBackground(Color.clear)
    }
}

#Preview {
    AboutHeaderView()
}
