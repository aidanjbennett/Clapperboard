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
            viewModel.changeVideo()
        } label: {
                Label("Change Video", systemImage: "arrow.triangle.2.circlepath")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.regular)
        .disabled(viewModel.isExporting || viewModel.selectedItem == nil)
    }
}
