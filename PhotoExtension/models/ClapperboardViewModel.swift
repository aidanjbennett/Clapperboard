//
//  ClapperboardViewModel.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 25/09/2025.
//

import PhotosUI
import AVFoundation
import UIKit

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
            print("ullSizeImageURL present: \(url)")
        } else {
            print("No audiovisualAsset or fullSizeImageURL available in the content editing input.")
            Task { @MainActor in
                self.isProcessing = false
            }
        }
    }
    
    func exportVideo() async -> PHContentEditingOutput? {
        guard let input = contentEditingInput else {
            print("No content editing input")
            return nil
        }
        
        // Try different ways to get the video URL
        var videoURL: URL?
        
        if let fullSizeURL = input.fullSizeImageURL {
            videoURL = fullSizeURL
            print("🎬 Using fullSizeImageURL: \(fullSizeURL)")
        } else if let asset = input.audiovisualAsset as? AVURLAsset {
            videoURL = asset.url
            print("🎬 Using audiovisualAsset URL: \(asset.url)")
        }
        
        guard let videoURL = videoURL else {
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
            print("🎬 Output URL will be: \(output.renderedContentURL)")
            
            // Create adjustment data
            let adjustmentData = PHAdjustmentData(
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
            output.adjustmentData = adjustmentData
            print("🎬 Adjustment data created")
            
            // Process the video
            try await processVideo(inputURL: videoURL, outputURL: output.renderedContentURL)
            
            // Verify output file exists
            let fileExists = FileManager.default.fileExists(atPath: output.renderedContentURL.path)
            print("Output file exists: \(fileExists)")
            
            if fileExists {
                let fileSize = try FileManager.default.attributesOfItem(atPath: output.renderedContentURL.path)[.size] as? Int64 ?? 0
                print("Output file size: \(fileSize) bytes")
            }
            
            await MainActor.run {
                self.isProcessing = false
            }
            
            print("Video export completed")
            return output
            
        } catch {
            print("Export error: \(error)")
            print("Error details: \(error.localizedDescription)")
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

        // Create composition
        let mixComposition = AVMutableComposition()
        guard let videoCompositionTrack = mixComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else { throw VideoProcessingError.noVideoTrack }

        try await videoCompositionTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: asset.load(.duration)),
            of: videoTrack,
            at: .zero
        )

        // Create video composition
        let videoSize = try await videoTrack.load(.naturalSize)
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)

        // Instruction for the whole video range
        let timeRange = try await CMTimeRange(start: .zero, duration: asset.load(.duration))
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = timeRange

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
        // No additional transforms
        mainInstruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [mainInstruction]

        // --- Overlay Layer ---
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: videoSize)
        videoLayer.frame = CGRect(origin: .zero, size: videoSize)
        parentLayer.addSublayer(videoLayer)

        // Generate clapperboard CGImage
        let clapperImage = await createClapperboardImage(size: videoSize)
        let overlayLayer = CALayer()
        overlayLayer.contents = clapperImage
        overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
        overlayLayer.opacity = 1.0
        parentLayer.addSublayer(overlayLayer)

        // Fade out after a short duration (e.g., 2 seconds)
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.duration = 0.5
        fadeAnimation.beginTime = AVCoreAnimationBeginTimeAtZero + 2.0
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.isRemovedOnCompletion = false
        fadeAnimation.fillMode = .forwards
        overlayLayer.add(fadeAnimation, forKey: "fade")

        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)

        // --- Export session ---
        guard let exportSession = AVAssetExportSession(
            asset: mixComposition,
            presetName: AVAssetExportPresetHighestQuality
        ) else { throw VideoProcessingError.exportSessionFailed }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = videoComposition

        // Remove previous output
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }

        try await withCheckedThrowingContinuation { continuation in
            exportSession.exportAsynchronously {
                if exportSession.status == .completed {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: exportSession.error ?? VideoProcessingError.exportSessionFailed)
                }
            }
        }
    }

    private func createClapperboardImage(size: CGSize) async -> CGImage {
        await withCheckedContinuation { continuation in
            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { context in
                let cgContext = context.cgContext
                
                // Fill background with white
                cgContext.setFillColor(UIColor.white.cgColor)
                cgContext.fill(CGRect(origin: .zero, size: size))
                
                // Calculate proportional sizes
                let scale = min(size.width / 1920, size.height / 1080)
                let clapperHeight = 200 * scale
                let stripeHeight = 60 * scale
                let fontSize = 36 * scale
                let smallFontSize = 24 * scale
                
                // Draw black and white stripes at top
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
                
                // Draw border around stripes
                cgContext.setStrokeColor(UIColor.black.cgColor)
                cgContext.setLineWidth(4)
                cgContext.stroke(stripesRect)
                
                // Draw info section
                let infoRect = CGRect(
                    x: 0,
                    y: stripeHeight,
                    width: size.width,
                    height: clapperHeight - stripeHeight
                )
                
                cgContext.setFillColor(UIColor.white.cgColor)
                cgContext.fill(infoRect)
                cgContext.stroke(infoRect)
                
                // Add text
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
                
                titleText.draw(
                    at: CGPoint(x: padding, y: yPos),
                    withAttributes: textAttributes
                )
                
                yPos += fontSize + 10
                sceneText.draw(
                    at: CGPoint(x: padding, y: yPos),
                    withAttributes: smallTextAttributes
                )
                
                yPos += smallFontSize + 5
                takeText.draw(
                    at: CGPoint(x: padding, y: yPos),
                    withAttributes: smallTextAttributes
                )
                
                // Right side text
                yPos = stripeHeight + padding + fontSize + 10
                let rightX = size.width - padding - 300 * scale
                
                directorText.draw(
                    at: CGPoint(x: rightX, y: yPos),
                    withAttributes: smallTextAttributes
                )
                
                yPos += smallFontSize + 5
                dateText.draw(
                    at: CGPoint(x: rightX, y: yPos),
                    withAttributes: smallTextAttributes
                )
            }
            
            continuation.resume(returning: image.cgImage!)
        }
    }
}

