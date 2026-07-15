//
//  VideoPickerView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 15/07/2026.
//

import SwiftUI
import PhotosUI

struct VideoPickerView: View {
    
    @Binding var selectedItem: PhotosPickerItem?
    let previewImage: UIImage?
    
    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .videos
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(.secondarySystemGroupedBackground), Color(.tertiarySystemGroupedBackground)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(.quaternary, lineWidth: 1)
                    }

                if let preview = previewImage {
                    Image(uiImage: preview)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                } else {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.12))
                                .frame(width: 44, height: 44)

                            Image(systemName: "video.badge.plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.accentColor)
                        }

                        Text("Select Video")
                            .font(.subheadline.weight(.semibold))

                        Text("Choose a clip to add your clapperboard to")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .frame(height: 140)
        }
        .buttonStyle(.plain)
    }
}
