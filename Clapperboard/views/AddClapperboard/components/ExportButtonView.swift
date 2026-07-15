//
//  ExportButtonView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 15/07/2026.
//

import SwiftUI

struct ExportButtonView: View {
    
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
                if viewModel.isExporting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Label("Export Video", systemImage: "square.and.arrow.up")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!viewModel.canExport)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isExporting)
    }
}
