//
//  AddClapperboardViewModel.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 15/07/2026.
//

import SwiftUI
import ClapperboardCore
import PhotosUI
import AVFoundation

@MainActor
@Observable
class AddClapperboardViewModel {

    var selectedItem: PhotosPickerItem?
    var selectedVideoURL: URL?

    var configuration: ClapperboardConfiguration = .default
    
    private var lastAppliedDefaultTitle: String
    private var lastAppliedDefaultDirector: String
    
    init() {
        let defaults = ClapperboardConfiguration.default
        lastAppliedDefaultTitle = defaults.title
        lastAppliedDefaultDirector = defaults.director
    }
    
    var previewImage: UIImage?
    var isRendering = false
    var isExporting = false

    var exportedVideoURL: URL?
    var error: Error?

    
    var hasVideo: Bool {
        selectedVideoURL != nil
    }

    var canExport: Bool {
        selectedVideoURL != nil && !isExporting
    }

    var formattedDate: String {
        configuration.selectedDate.formatted(
            date: .abbreviated,
            time: .omitted
        )
    }

    func loadSelectedVideo() async {
        guard let item = selectedItem else { return }

        do {
            guard let movie = try await item.loadTransferable(type: MovieTransferable.self) else {
                return
            }

            selectedVideoURL = movie.url
        } catch {
            self.error = error
        }
    }

    func renderPreview(size: CGSize) async {
        isRendering = true
        defer { isRendering = false }

        let cgImage = ClapperboardRenderer(configuration: configuration)
            .render(size: size)

        previewImage = UIImage(cgImage: cgImage)
    }

    func export() async {
        guard let inputURL = selectedVideoURL else { return }

        isExporting = true
        defer { isExporting = false }

        do {
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")

            let overlay = ClapperboardRenderer(configuration: configuration)
                .render(size: await VideoUtilities.videoSize(for: inputURL))

            try await VideoCompositor().process(
                inputURL: inputURL,
                outputURL: outputURL,
                overlayImage: overlay
            )

            exportedVideoURL = outputURL

        } catch {
            self.error = error
        }
    }

    func dismissShareSheet() {
        if let url = exportedVideoURL {
             try? FileManager.default.removeItem(at: url)
         }
        
        exportedVideoURL = nil
    }
    
    func changeVideo() {
        if let currentURL = selectedVideoURL {
              try? FileManager.default.removeItem(at: currentURL)
        }

        selectedItem = nil
        selectedVideoURL = nil
        previewImage = nil
        exportedVideoURL = nil
        error = nil
    }
    
    func refreshDefaultsIfNeeded() {
         let currentDefault = ClapperboardConfiguration.default

         if configuration.title == lastAppliedDefaultTitle {
             configuration.title = currentDefault.title
             lastAppliedDefaultTitle = currentDefault.title
         }

         if configuration.director == lastAppliedDefaultDirector {
             configuration.director = currentDefault.director
             lastAppliedDefaultDirector = currentDefault.director
         }
     }
}
