//
//  ExportButtonView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 15/07/2026.
//

import SwiftUI
import ClapperboardCore

struct ExportButtonView: View {
    
    var focusedField: FocusState<ClapperboardField?>.Binding
    @Binding var viewModel: AddClapperboardViewModel

    var body: some View {
        Button {
            focusedField.wrappedValue = nil
            Task {
                await viewModel.export()
                
                let incrementSceneNumber: Bool = UserDefaults.appGroup.bool(
                    forKey: UserDefaults.Keys.sceneAutoincrement
                )
                
                let incrementTakeNumber: Bool = UserDefaults.appGroup.bool(
                    forKey: UserDefaults.Keys.takeAutoincrement
                )
                
                if (incrementSceneNumber == true) {
                    autoIncrementSceneNumber()
                }
                
                if (incrementTakeNumber == true) {
                    autoIncrementTakeNumber()
                }
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
        .controlSize(.regular)
        .disabled(!viewModel.canExport)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isExporting)
    }
}
