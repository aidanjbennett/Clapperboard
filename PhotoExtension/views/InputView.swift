//
//  InputView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 14/10/2025.
//

import SwiftUI

struct InputView: View {
    let textFieldText: Binding<String>
    let textFieldTitle: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .fontWeight(.heavy)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1.2)

            TextField(textFieldTitle, text: textFieldText)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentColor)
                        .frame(width: 3)
                        .padding(.vertical, 8)
                        .padding(.leading, 4)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color(.separator), lineWidth: 0.5)
                )
        }
    }
}


#Preview {
//    InputView(, textFieldTitle: "Text Field Title", title: "Title")
}
