//
//  UIImage+Crop.swift
//  MyLife
//
//  Created by kunsh macbook on 12/9/26.
//


import UIKit

extension UIImage {
    func croppedToSquare(maxDimension: CGFloat = 1600) -> UIImage? {
        // Normalize orientation first
        let normalized = normalized()

        let side = min(
            normalized.size.width,
            normalized.size.height
        )

        let cropX = (normalized.size.width - side) / 2
        let cropY = (normalized.size.height - side) / 2

        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: side, height: side)
        )

        let square = renderer.image { _ in
            normalized.draw(
                at: CGPoint(
                    x: -cropX,
                    y: -cropY
                )
            )
        }

        // Resize to a reasonable size for MyLife
        let scale = min(1, maxDimension / side)

        if scale == 1 {
            return square
        }

        let newSize = CGSize(
            width: side * scale,
            height: side * scale
        )

        return UIGraphicsImageRenderer(size: newSize).image { _ in
            square.draw(in: CGRect(
                origin: .zero,
                size: newSize
            ))
        }
    }

    private func normalized() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
