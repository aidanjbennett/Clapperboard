//
//  FieldRowView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 15/07/2026.
//

import SwiftUI

struct FieldRowView: View {
    let icon: String
    let placeholder: String
    let field: ClapperboardField
    let focusedField: FocusState<ClapperboardField?>.Binding

    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .frame(width: 20)

            TextField(placeholder, text: $text)
                .focused(focusedField, equals: field)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
