import SwiftUI

struct FeaturePageView: View {
    var body: some View {
        VStack(spacing: 16) {

            Spacer()

            Image(systemName: "movieclapper")
                .font(.system(size: 70))
                .symbolRenderingMode(.hierarchical)

            Text("Make videos easier to identify")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)

            Text("Clapperboard adds a clapperboard image to your videos, helping you quickly recognise clips in your library.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    FeaturePageView()
}
