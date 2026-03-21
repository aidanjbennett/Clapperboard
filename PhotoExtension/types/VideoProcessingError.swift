//
//  VideoProcessingError.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 14/10/2025.
//

enum VideoProcessingError: Error {
    case noVideoTrack
    case exportSessionFailed
    case inputFileNotFound
    case assetNotPlayable
}
