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

@Observable
class ClapperboardViewModel {
    var contentEditingInput: PHContentEditingInput?
    var placeholderImage: UIImage?
    var isProcessing = false
    
    // Clapperboard configuration
    var title: String = "My Scene"
    var scene: String = "1"
    var take: String = "1"
    
    var director: String = UserDefaults(suiteName: "group.com.aidanjbennett.clapperboard")!.string(forKey: UserDefaults.Keys.name) ?? "John Doe"
    
    var date: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: Date())
    }
    
    func loadContent(contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        self.contentEditingInput = contentEditingInput
        self.placeholderImage = placeholderImage

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
            let error = VideoProcessingError.noMediaSource
            SentrySDK.capture(error: error)
            print("No audiovisualAsset or fullSizeImageURL available in the content editing input.")
            Task { @MainActor in
                self.isProcessing = false
            }
        }
    }
    
    func exportVideo() async -> PHContentEditingOutput? {
        guard let input = contentEditingInput else {
            let error = VideoProcessingError.noContentEditingInput
            SentrySDK.capture(error: error)
            print("No content editing input")
            return nil
        }
        
        var videoURL: URL?
        
        if let fullSizeURL = input.fullSizeImageURL {
            videoURL = fullSizeURL
            print("🎬 Using fullSizeImageURL: \(fullSizeURL)")
        } else if let asset = input.audiovisualAsset as? AVURLAsset {
            videoURL = asset.url
            print("🎬 Using audiovisualAsset URL: \(asset.url)")
        }
        
        guard let videoURL = videoURL else {
            let error = VideoProcessingError.noVideoURL
            SentrySDK.capture(error: error)
            print("No video URL found in any property")
            print("Available properties:")
            print("fullSizeImageURL: \(input.fullSizeImageURL?.absoluteString ?? "nil")")
            print("audiovisualAsset: \(input.audiovisualAsset != nil ? "present" : "nil")")
            print("mediaType: \(input.mediaType.rawValue)")
            return nil
        }
        
        await MainActor.run {
            isProcessing = true
        }
        
        print("Starting video export...")
        print("Input video URL: \(videoURL)")
        
        do {
            let output = PHContentEditingOutput(contentEditingInput: input)
            print("Output URL will be: \(output.renderedContentURL)")
            
            let adjustmentData: PHAdjustmentData
            do {
                adjustmentData = PHAdjustmentData(
                    formatIdentifier: "com.clapperboard.video-edit",
                    formatVersion: "1.0",
                    data: try JSONSerialization.data(withJSONObject: [
                        "title": title,
                        "scene": scene,
                        "take": take,
                        "director": director,
                        "date": date
                    ])
                )
            } catch {
                SentrySDK.capture(error: error)
                print("Failed to create adjustment data: \(error)")
                await MainActor.run { self.isProcessing = false }
                return nil
            }
            output.adjustmentData = adjustmentData
            print("Adjustment data created")
            
            try await processVideo(inputURL: videoURL, outputURL: output.renderedContentURL)
            
            let fileExists = FileManager.default.fileExists(atPath: output.renderedContentURL.path)
            print("Output file exists: \(fileExists)")
            
            if fileExists {
                do {
                    let fileSize = try FileManager.default.attributesOfItem(atPath: output.renderedContentURL.path)[.size] as? Int64 ?? 0
                    print("Output file size: \(fileSize) bytes")
                } catch {
                    SentrySDK.capture(error: error)
                    print("Failed to read output file attributes: \(error)")
                }
            } else {
                let error = VideoProcessingError.outputFileNotFound
                SentrySDK.capture(error: error)
                print("Output file not found after export")
                await MainActor.run { self.isProcessing = false }
                return nil
            }
            
            await MainActor.run {
                self.isProcessing = false
            }
            
            print("Video export completed")
            return output
            
        } catch {
            print("Export error: \(error)")
            print("Error details: \(error.localizedDescription)")
            SentrySDK.capture(error: error)
            await MainActor.run {
                self.isProcessing = false
            }
            return nil
        }
    }
    
    private func processVideo(inputURL: URL, outputURL: URL) async throws {
        let asset = AVURLAsset(url: inputURL)

        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw VideoProcessingError.noVideoTrack
        }

        let mixComposition = AVMutableComposition()
        guard let videoCompositionTrack = mixComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else { throw VideoProcessingError.compositionTrackFailed }

        do {
            try await videoCompositionTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: asset.load(.duration)),
                of: videoTrack,
                at: .zero
            )
        } catch {
            SentrySDK.capture(error: error)
            throw error
        }

        let videoSize: CGSize
        do {
            videoSize = try await videoTrack.load(.naturalSize)
        } catch {
            SentrySDK.capture(error: error)
            throw error
        }

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)

        let duration: CMTime
        do {
            duration = try await asset.load(.duration)
        } catch {
            SentrySDK.capture(error: error)
            throw error
        }

        let timeRange = CMTimeRange(start: .zero, duration: duration)
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = timeRange

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
        mainInstruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [mainInstruction]

        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: videoSize)
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        parentLayer.addSublayer(videoLayer)

        let clapperImage = await createClapperboardImage(size: videoSize)
        let overlayLayer = CALayer()
        overlayLayer.contents = clapperImage
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        overlayLayer.opacity = 1.0
        parentLayer.addSublayer(overlayLayer)

        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)

        guard let exportSession = AVAssetExportSession(
            asset: mixComposition,
            presetName: AVAssetExportPresetHighestQuality
        ) else { throw VideoProcessingError.exportSessionFailed }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = videoComposition

        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                try FileManager.default.removeItem(at: outputURL)
            } catch {
                SentrySDK.capture(error: error)
                throw error
            }
        }

        try await withCheckedThrowingContinuation { continuation in
            exportSession.exportAsynchronously {
                if exportSession.status == .completed {
                    continuation.resume()
                } else {
                    let error = exportSession.error ?? VideoProcessingError.exportSessionFailed
                    SentrySDK.capture(error: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func createClapperboardImage(size: CGSize) async -> CGImage {
        await withCheckedContinuation { continuation in
            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { context in
                let cgContext = context.cgContext
                
                cgContext.setFillColor(UIColor.white.cgColor)
                cgContext.fill(CGRect(origin: .zero, size: size))
                
                let scale = min(size.width / 1920, size.height / 1080)
                let clapperHeight = 200 * scale
                let stripeHeight = 60 * scale
                let fontSize = 36 * scale
                let smallFontSize = 24 * scale
                
                let stripesRect = CGRect(x: 0, y: 0, width: size.width, height: stripeHeight)
                let stripeWidth = size.width / 8
                
                for i in 0..<8 {
                    let color = i % 2 == 0 ? UIColor.black : UIColor.white
                    cgContext.setFillColor(color.cgColor)
                    let rect = CGRect(
                        x: CGFloat(i) * stripeWidth,
                        y: 0,
                        width: stripeWidth,
                        height: stripeHeight
                    )
                    cgContext.fill(rect)
                }
                
                cgContext.setStrokeColor(UIColor.black.cgColor)
                cgContext.setLineWidth(4)
                cgContext.stroke(stripesRect)
                
                let infoRect = CGRect(
                    x: 0,
                    y: stripeHeight,
                    width: size.width,
                    height: clapperHeight - stripeHeight
                )
                
                cgContext.setFillColor(UIColor.white.cgColor)
                cgContext.fill(infoRect)
                cgContext.stroke(infoRect)
                
                let titleText = "TITLE: \(title.uppercased())"
                let sceneText = "SCENE: \(scene)"
                let takeText = "TAKE: \(take)"
                let directorText = "DIRECTOR: \(director.uppercased())"
                let dateText = "DATE: \(date)"
                
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: fontSize),
                    .foregroundColor: UIColor.black
                ]
                
                let smallTextAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: smallFontSize),
                    .foregroundColor: UIColor.black
                ]
                
                let padding: CGFloat = 20 * scale
                var yPos = stripeHeight + padding
                
                titleText.draw(at: CGPoint(x: padding, y: yPos), withAttributes: textAttributes)
                
                yPos += fontSize + 10
                sceneText.draw(at: CGPoint(x: padding, y: yPos), withAttributes: smallTextAttributes)
                
                yPos += smallFontSize + 5
                takeText.draw(at: CGPoint(x: padding, y: yPos), withAttributes: smallTextAttributes)
                
                yPos = stripeHeight + padding + fontSize + 10
                let rightX = size.width - padding - 300 * scale
                
                directorText.draw(at: CGPoint(x: rightX, y: yPos), withAttributes: smallTextAttributes)
                
                yPos += smallFontSize + 5
                dateText.draw(at: CGPoint(x: rightX, y: yPos), withAttributes: smallTextAttributes)
            }
            
            guard let cgImage = image.cgImage else {
                let error = VideoProcessingError.clapperboardRenderFailed
                SentrySDK.capture(error: error)
                // Return a 1x1 transparent fallback to avoid a force-unwrap crash
                let fallback = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
                    .image { _ in }
                continuation.resume(returning: fallback.cgImage!)
                return
            }
            continuation.resume(returning: cgImage)
        }
    }
}