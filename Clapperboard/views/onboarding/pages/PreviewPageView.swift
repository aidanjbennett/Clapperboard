import SwiftUI

struct PreviewPageView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            // Fake Photos preview
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 280)

                VStack(spacing: 10) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.secondary)
                    Text("Photos App")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            Text("Photos → Video → Edit → Extensions → Clapperboard")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PreviewPageView()
}
