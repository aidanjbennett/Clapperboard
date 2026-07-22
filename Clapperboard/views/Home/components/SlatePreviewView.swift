//
//  SlatePreviewView.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 22/07/2026.
//

import SwiftUI
import ClapperboardCore

struct SlatePreviewView: View {
    
    let name: String
    let title: String
    
    @State private var previewImage: UIImage?
    private let previewSize = CGSize(width: 320, height: 90)
    
    var body: some View {
           ZStack {
               Color.black
               if let previewImage {
                   Image(uiImage: previewImage)
                       .resizable()
                       .aspectRatio(contentMode: .fill)
               }
           }
           .frame(height: previewSize.height)
           .clipShape(RoundedRectangle(cornerRadius: 10))
           .task(id: "\(name)|\(title)") {
               await renderPreview()
           }
       }

     private func renderPreview() async {
           var configuration = ClapperboardConfiguration.default
           configuration.director = name.isEmpty ? "Your name" : name
           configuration.title = title.isEmpty ? "Scene title" : title
           configuration.selectedDate = .now

           let renderer = ClapperboardRenderer(configuration: configuration)
           let cgImage =  renderer.render(size: previewSize)
           previewImage = UIImage(cgImage: cgImage)
       }
}

#Preview {
    SlatePreviewView(name: "Aidan Bennett", title: "My title")
}
