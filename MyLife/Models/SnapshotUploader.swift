//
//  SnapshotUploader.swift
//  MyLife
//
//  Created by kunsh macbook on 12/9/26.
//


import UIKit
import Supabase

enum SnapshotUploader {

    static func upload(_ image: UIImage) async throws {

        guard let squareImage = image.croppedToSquare(
            maxDimension: 1600
        ) else {
            throw UploadError.cropFailed
        }

        guard let data = ImageCompressor.compress(
            squareImage,
            maxBytes: 3 * 1024 * 1024
        ) else {
            throw UploadError.compressionFailed
        }

        let filename = "\(UUID().uuidString).jpg"

        try await supabase.storage
            .from("snapshots")
            .upload(
                filename,
                data: data,
                options: FileOptions(
                    contentType: "image/jpeg",
                    upsert: false
                )
            )

        print("Uploaded:", filename)
    }
}

enum UploadError: LocalizedError {
    case cropFailed
    case compressionFailed

    var errorDescription: String? {
        switch self {
        case .cropFailed:
            return "Couldn't crop the image."
        case .compressionFailed:
            return "Couldn't compress the image."
        }
    }
}