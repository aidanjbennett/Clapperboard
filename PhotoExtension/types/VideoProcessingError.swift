//
//  VideoProcessingError.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 14/10/2025.
//

import Foundation
 
enum VideoProcessingError: Error, LocalizedError {
    case noContentEditingInput
    case noMediaSource
    case noVideoURL
    case noVideoTrack
    case compositionTrackFailed
    case exportSessionFailed
    case outputFileNotFound
    case clapperboardRenderFailed
    
    var errorDescription: String? {
        switch self {
        case .noContentEditingInput:   return "No content editing input available."
        case .noMediaSource:           return "No media source found in content editing input."
        case .noVideoURL:              return "Could not resolve a video URL from the asset."
        case .noVideoTrack:            return "The asset contains no video track."
        case .compositionTrackFailed:  return "Failed to create a mutable composition track."
        case .exportSessionFailed:     return "Failed to create an AVAssetExportSession."
        case .outputFileNotFound:      return "Output file was not found after export."
        case .clapperboardRenderFailed: return "Failed to render the clapperboard image."
        }
    }
}
