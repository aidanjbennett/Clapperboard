//
//  VideoUtilities.swift
//  ClapperboardCore
//
//  Created by Aidan Bennett on 14/07/2026.
//

import AVFoundation
import Foundation

public enum VideoUtilities {

    public static func videoSize(for url: URL) async -> CGSize {
        let asset = AVURLAsset(url: url)

        guard let track = try? await asset.loadTracks(withMediaType: .video).first else {
            return CGSize(width: 1080, height: 1920)
        }

        do {
            let naturalSize = try await track.load(.naturalSize)
            let transform = try await track.load(.preferredTransform)

            let isPortrait = abs(transform.b) == 1 && abs(transform.c) == 1

            return isPortrait
                ? CGSize(width: naturalSize.height, height: naturalSize.width)
                : naturalSize
        } catch {
            return CGSize(width: 1080, height: 1920)
        }
    }
}
