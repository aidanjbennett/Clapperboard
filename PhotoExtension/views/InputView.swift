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
        HStack {
            Text(title)
                .frame(width: 80, alignment: .leading)
            TextField(textFieldTitle, text: textFieldText)
                .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview {
//    InputView(, textFieldTitle: "Text Field Title", title: "Title")
}
