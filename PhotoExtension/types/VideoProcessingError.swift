//
//  VideoProcessingError.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 14/10/2025.
//

enum VideoProcessingError: Error {
    case noContentEditingInput
    case noMediaSource
    case noVideoURL
    case noVideoTrack
    case compositionTrackFailed
    case exportSessionFailed
    case outputFileNotFound
    case clapperboardRenderFailed
}