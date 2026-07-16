//
//  ChangeVideoButtonView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 16/07/2026.
//

import SwiftUI

struct ChangeVideoButtonView: View {
    
    var focusedField: FocusState<ClapperboardField?>.Binding
    @Binding var viewModel: AddClapperboardViewModel

    var body: some View {
        Button {
            focusedField.wrappedValue = nil
            Task {
                await viewModel.export()
            }
        } label: {
            HStack {
                Label("Change Video", systemImage: "square.and.arrow.up")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.regular)
        .disabled(!viewModel.canExport)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isExporting)
    }
}
