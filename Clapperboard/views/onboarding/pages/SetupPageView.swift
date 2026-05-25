import SwiftUI

struct SetupPageView: View {
    @Binding var nameInput: String
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "person.circle")
                .font(.system(size: 70))
                .symbolRenderingMode(.hierarchical)
            Text("Let’s personalise it")
                .font(.title)
                .bold()
            Text("What should we call you?")
                .foregroundStyle(.secondary)
            TextField("Enter your name", text: $nameInput)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)
                .padding(.top, 10)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var name = "John Doe"
    SetupPageView(nameInput: $name)
}
