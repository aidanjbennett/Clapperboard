//
//  VideoCompositor.swift
//  ClapperboardCore
//
//  Created by Aidan Bennett on 13/05/2026.
//

import Foundation
import AVFoundation
import CoreImage
import Sentry

public struct VideoCompositor: Sendable {

    public init() {}

    public func process(inputURL: URL, outputURL: URL, overlayImage: CGImage) async throws {
        let asset = AVURLAsset(url: inputURL)

        guard let sourceTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw VideoProcessingError.noVideoTrack
        }

        let (composition, compositionTrack) = try await buildComposition(from: asset, sourceTrack: sourceTrack)
        let transform = try await sourceTrack.load(.preferredTransform)
        let naturalSize = try await sourceTrack.load(.naturalSize)
        let videoSize = transformedSize(naturalSize: naturalSize, transform: transform)
        let duration = try await asset.load(.duration)

        let videoComposition = await Self.buildVideoComposition(
            size: videoSize,
            duration: duration,
            compositionTrack: compositionTrack,
            preferredTransform: transform,
            overlayImage: overlayImage
        )

        try await export(composition: composition, videoComposition: videoComposition, to: outputURL)
    }

    // MARK: - Composition

    private func buildComposition(
        from asset: AVURLAsset,
        sourceTrack: AVAssetTrack
    ) async throws -> (AVMutableComposition, AVMutableCompositionTrack) {
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
                of: sourceTrack,
                at: .zero
            )
        } catch {
            SentrySDK.capture(error: error)
            throw error
        }

        return (composition, compositionTrack)
    }

    private func transformedSize(naturalSize: CGSize, transform: CGAffineTransform) -> CGSize {
        let isPortrait = abs(transform.b) == 1 && abs(transform.c) == 1
        return isPortrait
            ? CGSize(width: naturalSize.height, height: naturalSize.width)
            : naturalSize
    }

    private static func buildVideoComposition(
        size: CGSize,
        duration: CMTime,
        compositionTrack: AVMutableCompositionTrack,
        preferredTransform: CGAffineTransform,
        overlayImage: CGImage
    ) async -> AVMutableVideoComposition {
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = size
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.instructions = [
            makeInstruction(for: compositionTrack, duration: duration, transform: preferredTransform)
        ]
        videoComposition.animationTool = await makeAnimationTool(
            size: size,
            duration: duration,
            overlayImage: overlayImage
        )
        return videoComposition
    }

    private static func makeInstruction(
        for track: AVMutableCompositionTrack,
        duration: CMTime,
        transform: CGAffineTransform
    ) -> AVMutableVideoCompositionInstruction {
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        layerInstruction.setTransform(transform, at: .zero)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: duration)
        instruction.layerInstructions = [layerInstruction]
        return instruction
    }

    private static func makeAnimationTool(
        size: CGSize,
        duration: CMTime,
        overlayImage: CGImage
    ) async -> AVVideoCompositionCoreAnimationTool {
        await MainActor.run {
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
    }

    private static func makeThumbnailOnlyOverlayLayer(
        image: CGImage,
        size: CGSize,
        duration: CMTime
    ) -> CALayer {
        let layer = CALayer()
        layer.contents = image
        layer.frame = CGRect(origin: .zero, size: size)
        layer.opacity = 1.0

        let totalSeconds = duration.seconds
        guard totalSeconds.isFinite, totalSeconds > 0 else {
            return layer
        }

        let frameSeconds = 1.0 / 30.0
        let thumbnailEndFraction = min(max(frameSeconds / totalSeconds, 0.0001), 0.999)

        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [1.0, 1.0, 0.0]
        animation.keyTimes = [
            0.0,
            NSNumber(value: thumbnailEndFraction),
            1.0
        ]
        animation.duration = totalSeconds
        animation.beginTime = AVCoreAnimationBeginTimeAtZero
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
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
