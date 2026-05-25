//
//  ConfigurationView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 14/10/2025.
//

import SwiftUI

struct ConfigurationView: View {
    
    let viewModelTitle: Binding<String>
    let viewModelScene: Binding<String>
    let viewModelTake: Binding<String>
    let viewModelDirector: Binding<String>
    let viewModelDate: Binding<Date>
    
    var body: some View {
        // Clapperboard Configuration
        VStack(spacing: 16) {
            Text("Clapperboard Details")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                InputView(textFieldText: viewModelTitle, textFieldTitle: "Scene Title", title: "Title:")
                InputView(textFieldText: viewModelScene, textFieldTitle: "1", title: "Scene:")
                InputView(textFieldText: viewModelTake, textFieldTitle: "1", title: "Take:")
                InputView(textFieldText: viewModelDirector, textFieldTitle: "Your name", title: "Director:")
            }
            
            // Date Picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Date:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                DatePicker(
                    "Select Date",
                    selection: viewModelDate,
                    displayedComponents: .date
                )
                .labelsHidden()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    //    ConfigurationView()
}
