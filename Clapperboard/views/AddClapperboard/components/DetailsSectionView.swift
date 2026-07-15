//
//  DetailsSectionView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 15/07/2026.
//

import SwiftUI
import ClapperboardCore

struct DetailsSectionView: View {
    
    @Binding var configuration: ClapperboardConfiguration
    let focusedField: FocusState<ClapperboardField?>.Binding
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Details")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                FieldRowView(
                    icon: "textformat",
                    placeholder: "Title",
                    field: .title,
                    focusedField: focusedField,
                    text: $configuration.title,
                )

                Divider().padding(.leading, 44)

                FieldRowView(
                    icon: "person",
                    placeholder: "Director",
                    field: .director, focusedField: focusedField,
                    text: $configuration.director
                )

                Divider().padding(.leading, 44)

                HStack(spacing: 0) {
                    FieldRowView(
                        icon: "film",
                        placeholder: "Scene",
                        field: .scene,
                        focusedField: focusedField,
                        text: $configuration.scene,
                    )

                    Divider()
                        .frame(height: 24)

                    FieldRowView(
                        icon: "number",
                        placeholder: "Take",
                        field: .take,
                        focusedField: focusedField,
                        text: $configuration.take,
                    )
                }

                Divider().padding(.leading, 44)

                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .frame(width: 20)

                    DatePicker(
                        "Date",
                        selection: $configuration.selectedDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}
