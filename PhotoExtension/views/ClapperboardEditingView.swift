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
        VStack(spacing: 20) {
            HeaderView()
            
            // Preview
            if let placeholderImage = viewModel.placeholderImage {
                VStack {
                    Text("Video Preview")
                        .font(.headline)
                    
                    Image(uiImage: placeholderImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            }
            
            ConfigurationView(
                viewModelTitle: $viewModel.title,
                viewModelScene: $viewModel.scene,
                viewModelTake: $viewModel.take,
                viewModelDirector: $viewModel.director
            )
            
            if viewModel.isProcessing {
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Adding clapperboard to video...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
    
    func loadContent(contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        viewModel.loadContent(contentEditingInput: contentEditingInput, placeholderImage: placeholderImage)
    }
    
    // Modern async/await version
    func exportVideo() async -> PHContentEditingOutput? {
        // Cancel any existing export task
        exportTask?.cancel()
        
        // Create and store the new task
        let task = Task {
            await viewModel.exportVideo()
        }
        exportTask = task
        
        return await task.value
    }
    
    // Backward compatibility wrapper for completion handler APIs
    func exportVideo(completionHandler: @escaping (PHContentEditingOutput?) -> Void) {
        Task {
            let output = await exportVideo()
            completionHandler(output)
        }
    }
}

#Preview {
    ClapperboardEditingView()
}
