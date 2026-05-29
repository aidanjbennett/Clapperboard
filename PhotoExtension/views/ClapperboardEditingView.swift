//
//  ClapperboardEditingView.swift
//  ClapperEdit
//
//  Created by Aidan Bennett on 25/09/2025.
//

import SwiftUI
import Photos

struct ClapperboardEditingView: View {
    @State private var viewModel = ClapperboardViewModel()
    @State private var exportTask: Task<PHContentEditingOutput?, Never>?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Clapperboard Configuration
                VStack(alignment: .leading, spacing: 20) {

                    Label("Clapperboard Details", systemImage: "film.clapper")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    if let placeholderImage = viewModel.placeholderImage {

                        VStack(spacing: 12) {

                            // Preview
                            Image(uiImage: placeholderImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(
                                            Color(.separator),
                                            lineWidth: 0.5
                                        )
                                )

                            // Scene + Take
                            HStack(spacing: 12) {

                                InputView(
                                    textFieldText: $viewModel.scene,
                                    textFieldTitle: "1",
                                    title: "Scene"
                                )

                                InputView(
                                    textFieldText: $viewModel.take,
                                    textFieldTitle: "1",
                                    title: "Take"
                                )
                            }

                            Divider()

                            // Title + Director
                            HStack(spacing: 12) {

                                InputView(
                                    textFieldText: $viewModel.title,
                                    textFieldTitle: "Scene title",
                                    title: "Title"
                                )

                                InputView(
                                    textFieldText: $viewModel.director,
                                    textFieldTitle: "Your name",
                                    title: "Director"
                                )
                            }

                            // Date
                            DateInputView(
                                title: "Date",
                                date: $viewModel.date
                            )
                        }
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(
                    color: .black.opacity(0.06),
                    radius: 8,
                    x: 0,
                    y: 2
                )

                if viewModel.isProcessing {
                    VStack(spacing: 8) {

                        ProgressView()
                            .scaleEffect(1.2)

                        Text("Adding clapperboard to video...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }

                Spacer(minLength: 0)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(minHeight: UIScreen.main.bounds.height - 32)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    func loadContent(
        contentEditingInput: PHContentEditingInput,
        placeholderImage: UIImage
    ) {
        viewModel.loadContent(
            contentEditingInput: contentEditingInput,
            placeholderImage: placeholderImage
        )
    }

    func exportVideo() async -> PHContentEditingOutput? {
        exportTask?.cancel()

        let task = Task {
            await viewModel.exportVideo()
        }

        exportTask = task

        return await task.value
    }

    func exportVideo(
        completionHandler: @escaping (PHContentEditingOutput?) -> Void
    ) {
        Task {
            let output = await exportVideo()
            completionHandler(output)
        }
    }
}

#Preview {
    ClapperboardEditingView()
}
