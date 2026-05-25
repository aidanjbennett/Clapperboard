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

extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.com.aidanjbennett.clapperboard")!

    enum Keys {
        static let name = "name"
    }
}

/// Orchestrates the Photos editing lifecycle and delegates all heavy work to
/// `ClapperboardRenderer` and `VideoCompositor`.
@Observable
class ClapperboardViewModel {

    // MARK: - State

    var contentEditingInput: PHContentEditingInput?
    var placeholderImage: UIImage?
    var isProcessing = false

    // MARK: - Clapperboard configuration (exposed for the UI)

    var configuration: ClapperboardConfiguration = .default

    // Convenience pass-throughs so existing view bindings keep working
    var title:    String { get { configuration.title }    set { configuration.title    = newValue } }
    var scene:    String { get { configuration.scene }    set { configuration.scene    = newValue } }
    var take:     String { get { configuration.take }     set { configuration.take     = newValue } }
    var director: String { get { configuration.director } set { configuration.director = newValue } }
    var date: Date { get { configuration.selectedDate }   set { configuration.selectedDate = newValue } }

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

            await MainActor.run { isProcessing = false }
            return output
        } catch {
            SentrySDK.capture(error: error)
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
            .render(size: await videoSize(for: inputURL))

        try await VideoCompositor().process(
            inputURL: inputURL,
            outputURL: outputURL,
            overlayImage: overlayImage
        )
    }

    /// Reads the display size of the first video track (natural size with the
    /// preferred transform applied) so the renderer produces a correctly-oriented
    /// overlay. Falls back to 1080×1920 (portrait) if loading fails.
    private func videoSize(for url: URL) async -> CGSize {
        let asset = AVURLAsset(url: url)
        // Synchronous snapshot – acceptable here because we're already on a
        // background task and only need an approximate size for layout.
        guard let track = try? await asset.load(.tracks).first(where: { $0.mediaType == .video }) else {
            return CGSize(width: 1080, height: 1920)
        }

        do {
            let natural = try await track.load(.naturalSize)
            let transform = try await track.load(.preferredTransform)
                        
            let isPortrait = abs(transform.b) == 1 && abs(transform.c) == 1
            return isPortrait
                ? CGSize(width: natural.height, height: natural.width)
                : natural
        } catch {
            return CGSize(width: 1080, height: 1920)
        }
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
        print("  fullSizeImageURL: \(input.fullSizeImageURL?.absoluteString ?? "nil")")
        print("  audiovisualAsset: \(input.audiovisualAsset != nil ? "present" : "nil")")
        print("  mediaType: \(input.mediaType.rawValue)")
    }
}

