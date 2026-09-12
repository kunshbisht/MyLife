//
//  ImageCompressor.swift
//  MyLife
//
//  Created by kunsh macbook on 12/9/26.
//


import UIKit

enum ImageCompressor {

    static func compress(
        _ image: UIImage,
        maxBytes: Int = 3 * 1024 * 1024
    ) -> Data? {

        // Start at high quality
        var quality: CGFloat = 0.9

        // Gradually reduce JPEG quality until we're under the limit
        while quality >= 0.1 {
            if let data = image.jpegData(compressionQuality: quality) {
                if data.count <= maxBytes {
                    return data
                }
            }

            quality -= 0.05
        }

        // If quality compression isn't enough,
        // resize the image and try again.
        var resizedImage = image
        var scale: CGFloat = 0.8

        while scale >= 0.2 {
            let newSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )

            let renderer = UIGraphicsImageRenderer(size: newSize)

            resizedImage = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }

            if let data = resizedImage.jpegData(compressionQuality: 0.8),
               data.count <= maxBytes {
                return data
            }

            scale -= 0.1
        }

        return nil
    }
}