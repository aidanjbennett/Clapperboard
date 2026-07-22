//
//  ClapperboardViewModel.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 25/09/2025.
//

import PhotosUI
import AVFoundation
import UIKit
import Sentry
import ClapperboardCore
import PostHog

/// Orchestrates the Photos editing lifecycle and delegates all heavy work to
/// `ClapperboardRenderer` and `VideoCompositor`.
@Observable
class ClapperboardViewModel {
    
    var contentEditingInput: PHContentEditingInput?
    var placeholderImage: UIImage?
    var isProcessing = false

    var configuration: ClapperboardConfiguration

    @MainActor
    init() {
        self.configuration = .default

        let posthogConfig = PostHogConfig(
            projectToken: "phc_oh8fPqMsoXbVg6Bxwu2f3CeZbtAKznm4AFteUppFfYDS",
            host: "https://eu.i.posthog.com"
        )
        posthogConfig.appGroupIdentifier = "group.com.aidanjbennett.clapperboard"
        PostHogSDK.shared.setup(posthogConfig)
    }

    // Formatted date string for rendering on the clapperboard
    var formattedDate: String {
        configuration.selectedDate.formatted(
            date: .abbreviated,
            time: .omitted
        )
    }
    
    // MARK: - Photos lifecycle

    func loadContent(contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        self.contentEditingInput = contentEditingInput
        self.placeholderImage    = placeholderImage

        let mediaType = contentEditingInput.mediaType
        print("Media type: \(mediaType.rawValue)")

        if let asset = contentEditingInput.audiovisualAsset {
            print("audiovisualAsset present: \(asset)")
            if let url = (asset as? AVURLAsset)?.url {
                print("Asset URL: \(url)")
            }
        } else if let url = contentEditingInput.fullSizeImageURL {
            print("fullSizeImageURL present: \(url)")
        } else {
            SentrySDK.capture(error: VideoProcessingError.noMediaSource)
            print("No audiovisualAsset or fullSizeImageURL available.")
            isProcessing = false
        }
    }

    // MARK: - Export

    func exportVideo() async -> PHContentEditingOutput? {
        guard let input = contentEditingInput else {
            SentrySDK.capture(error: VideoProcessingError.noContentEditingInput)
            return nil
        }

        guard let videoURL = resolveVideoURL(from: input) else {
            SentrySDK.capture(error: VideoProcessingError.noVideoURL)
            logURLDiagnostics(for: input)
            return nil
        }

        await MainActor.run { isProcessing = true }

        do {
            let output = try makeOutput(for: input)
            try await processVideo(inputURL: videoURL, outputURL: output.renderedContentURL)
            try verifyOutput(at: output.renderedContentURL)

            PostHogSDK.shared.capture("extension_export_completed")
            await MainActor.run { isProcessing = false }
            return output
        } catch {
            SentrySDK.capture(error: error)
            PostHogSDK.shared.capture("extension_export_failed", properties: [
                "error_message": error.localizedDescription,
            ])
            print("Export error: \(error) — \(error.localizedDescription)")
            await MainActor.run { isProcessing = false }
            return nil
        }
    }

    // MARK: - Private helpers

    private func resolveVideoURL(from input: PHContentEditingInput) -> URL? {
        if let url = input.fullSizeImageURL {
            print("Using fullSizeImageURL: \(url)")
            return url
        }
        if let url = (input.audiovisualAsset as? AVURLAsset)?.url {
            print("Using audiovisualAsset URL: \(url)")
            return url
        }
        return nil
    }

    private func makeOutput(for input: PHContentEditingInput) throws -> PHContentEditingOutput {
        let output = PHContentEditingOutput(contentEditingInput: input)
        output.adjustmentData = PHAdjustmentData(
            formatIdentifier: "com.clapperboard.video-edit",
            formatVersion: "1.0",
            data: try configuration.toAdjustmentDataPayload()
        )
        return output
    }

    private func processVideo(inputURL: URL, outputURL: URL) async throws {
        let overlayImage = await ClapperboardRenderer(configuration: configuration)
            .render(size: await VideoUtilities.videoSize(for: inputURL))

        try await VideoCompositor().process(
            inputURL: inputURL,
            outputURL: outputURL,
            overlayImage: overlayImage
        )
    }

    private func verifyOutput(at url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw VideoProcessingError.outputFileNotFound
        }
        if let size = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 {
            print("Output file size: \(size) bytes")
        }
    }

    private func logURLDiagnostics(for input: PHContentEditingInput) {
        print("No video URL found. Available properties:")
        print("fullSizeImageURL: \(input.fullSizeImageURL?.absoluteString ?? "nil")")
        print("audiovisualAsset: \(input.audiovisualAsset != nil ? "present" : "nil")")
        print("mediaType: \(input.mediaType.rawValue)")
    }
}

