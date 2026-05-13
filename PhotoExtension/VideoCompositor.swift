//
//  VideoCompositor.swift
//  PhotoExtension
//
//  Created by Aidan Bennett on 13/05/2026.
//

import Foundation
import AVFoundation
import CoreImage
import Sentry

/// Handles all AVFoundation work: building the composition, attaching the
/// clapperboard overlay via Core Animation, and exporting the final file.
/// Has no dependency on Photos or UIKit (the overlay image is injected).
struct VideoCompositor {

    // MARK: - Public entry point

    func process(inputURL: URL, outputURL: URL, overlayImage: CGImage) async throws {
        let asset = AVURLAsset(url: inputURL)

        let (composition, videoCompositionTrack) = try await buildComposition(from: asset)
        let videoSize = try await loadVideoSize(from: asset)
        let duration  = try await asset.load(.duration)
        let videoComposition = buildVideoComposition(
            size: videoSize,
            duration: duration,
            compositionTrack: videoCompositionTrack,
            overlayImage: overlayImage
        )

        try await export(composition: composition, videoComposition: videoComposition, to: outputURL)
    }

    // MARK: - Composition

    private func buildComposition(
        from asset: AVURLAsset
    ) async throws -> (AVMutableComposition, AVMutableCompositionTrack) {
        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw VideoProcessingError.noVideoTrack
        }

        let composition = AVMutableComposition()

        guard let compositionTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw VideoProcessingError.compositionTrackFailed
        }

        do {
            try await compositionTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: asset.load(.duration)),
                of: videoTrack,
                at: .zero
            )
        } catch {
            SentrySDK.capture(error: error)
            throw error
        }

        return (composition, compositionTrack)
    }

    private func loadVideoSize(from asset: AVURLAsset) async throws -> CGSize {
        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw VideoProcessingError.noVideoTrack
        }
        do {
            return try await videoTrack.load(.naturalSize)
        } catch {
            SentrySDK.capture(error: error)
            throw error
        }
    }

    // MARK: - Video composition

    private func buildVideoComposition(
        size: CGSize,
        duration: CMTime,
        compositionTrack: AVMutableCompositionTrack,
        overlayImage: CGImage
    ) -> AVMutableVideoComposition {
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = size
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.instructions = [makeInstruction(for: compositionTrack, duration: duration)]
        videoComposition.animationTool = makeAnimationTool(
            size: size,
            duration: duration,
            overlayImage: overlayImage
        )
        return videoComposition
    }

    private func makeInstruction(
        for track: AVMutableCompositionTrack,
        duration: CMTime
    ) -> AVMutableVideoCompositionInstruction {
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: duration)
        instruction.layerInstructions = [
            AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        ]
        return instruction
    }

    // MARK: - Core Animation tool

    private func makeAnimationTool(
        size: CGSize,
        duration: CMTime,
        overlayImage: CGImage
    ) -> AVVideoCompositionCoreAnimationTool {
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: size)

        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: size)
        parentLayer.addSublayer(videoLayer)

        let overlayLayer = makeThumbnailOnlyOverlayLayer(
            image: overlayImage,
            size: size,
            duration: duration
        )
        parentLayer.addSublayer(overlayLayer)

        return AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: parentLayer
        )
    }

    /// Returns a `CALayer` that shows `image` only on the first frame, then
    /// immediately hides itself so it acts as a thumbnail-only watermark.
    private func makeThumbnailOnlyOverlayLayer(
        image: CGImage,
        size: CGSize,
        duration: CMTime
    ) -> CALayer {
        let layer = CALayer()
        layer.contents = image
        layer.frame = CGRect(origin: .zero, size: size)
        layer.opacity = 1.0

        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values   = [1.0, 1.0, 0.0]
        animation.keyTimes = [
            0.0,
            NSNumber(value: 1.0 / 30.0 / duration.seconds),
            NSNumber(value: 1.0 / 30.0 / duration.seconds)
        ]
        animation.duration            = duration.seconds
        animation.beginTime           = AVCoreAnimationBeginTimeAtZero
        animation.isRemovedOnCompletion = false
        animation.fillMode            = .forwards
        layer.add(animation, forKey: "thumbnailOnly")

        return layer
    }

    // MARK: - Export

    private func export(
        composition: AVMutableComposition,
        videoComposition: AVMutableVideoComposition,
        to outputURL: URL
    ) async throws {
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            throw VideoProcessingError.exportSessionFailed
        }

        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = videoComposition

        try removeExistingFile(at: outputURL)

        do {
            try await exportSession.export(to: outputURL, as: .mov)
        } catch {
            SentrySDK.capture(error: error)
            throw error
        }
    }

    private func removeExistingFile(at url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            SentrySDK.capture(error: error)
            throw error
        }
    }
}
