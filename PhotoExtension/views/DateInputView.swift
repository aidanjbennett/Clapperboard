//
//  DateInputView.swift
//  PhotoExtension
//
//  Created by Aidan Bennett on 29/05/2026.
//

import SwiftUI

struct DateInputView: View {
    let title: String
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .fontWeight(.heavy)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1.2)

            DatePicker(
                "",
                selection: $date,
                displayedComponents: .date
            )
            .labelsHidden()
            .font(.system(.body, design: .monospaced))
            .datePickerStyle(.compact)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
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

//#Preview {
//    DateInputView()
//}
