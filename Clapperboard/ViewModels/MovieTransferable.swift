//
//  MovieTransferable.swift
//  Clapperboard
//
//  Created by Aidan Bennett on 14/07/2026.
//

import Foundation
import CoreTransferable
internal import UniformTypeIdentifiers

struct MovieTransferable: Transferable {

    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .movie) { received in
            let sourceURL = received.file

            let destinationURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(sourceURL.pathExtension)

            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }

            try FileManager.default.copyItem(
                at: sourceURL,
                to: destinationURL
            )

            return MovieTransferable(url: destinationURL)
        }
    }
}
