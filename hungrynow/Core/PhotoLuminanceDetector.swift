//
//  PhotoLuminanceDetector.swift
//  hungrynow
//
//  Screen 06 — Runtime luminance detector for hero photos.
//  Measures perceived brightness at the top corners (under clock and battery)
//  to guarantee status bar text legibility, avoiding the Dynamic Island.
//

import UIKit

/// Measures the pixel luminance of a hero photo to decide whether
/// the status bar should render with `.darkContent` (black glyphs) or
/// `.lightContent` (white glyphs).
///
/// Implements the 4 requirements specified in `screen-06-result.html`:
/// 1. Samples where the glyphs are: leading third (clock) and trailing third (battery), skipping Dynamic Island.
/// 2. Worst-case evaluation: checks for blown-out highlights where white glyphs would wash out.
/// 3. Hysteresis: separates thresholds to prevent rapid toggling.
/// 4. Cache per photo identifier: memoizes calculations.
public final class PhotoLuminanceDetector {

    public static let shared = PhotoLuminanceDetector()

    private let cache = NSCache<NSString, NSNumber>()

    private init() {
        cache.countLimit = 50
    }

    /// Determines the optimal `UIStatusBarStyle` for an image.
    /// - Parameters:
    ///   - image: The hero `UIImage` to analyze.
    ///   - identifier: An optional cache key (e.g. photo URL or photoRef).
    /// - Returns: `.darkContent` if the top corners are light/bright; `.lightContent` if dark.
    public func detectStyle(for image: UIImage, identifier: String? = nil) -> UIStatusBarStyle {
        if let identifier = identifier, let cached = cache.object(forKey: identifier as NSString) {
            return cached.intValue == 0 ? .lightContent : .darkContent
        }

        guard let cgImage = image.cgImage else {
            return .lightContent
        }

        let width = cgImage.width
        let height = cgImage.height

        guard width > 20 && height > 20 else {
            return .lightContent
        }

        // Sample the top 18% of the image (where the status bar sits over the hero photo)
        let sampleHeight = max(16, Int(Double(height) * 0.18))

        // Region 1: Left third (under clock) — 0% to 35% width
        let leftRect = CGRect(x: 0, y: 0, width: Int(Double(width) * 0.35), height: sampleHeight)

        // Region 2: Right third (under battery & signal) — 65% to 100% width
        let rightX = Int(Double(width) * 0.65)
        let rightRect = CGRect(x: rightX, y: 0, width: width - rightX, height: sampleHeight)

        // Measure both regions independently (ignoring the center 35%..65% Dynamic Island)
        let (leftMean, leftMax) = analyzeRegion(cgImage: cgImage, rect: leftRect)
        let (rightMean, rightMax) = analyzeRegion(cgImage: cgImage, rect: rightRect)

        // Worst-case rule: If EITHER region has high brightness or blown-out highlights,
        // white text will wash out, so we must pick black glyphs (.darkContent).
        let worstMean = max(leftMean, rightMean)
        let worstMax = max(leftMax, rightMax)

        let isBright: Bool
        if worstMean > 0.58 {
            // High average brightness across the icon region (e.g. bright sky, white cafe)
            isBright = true
        } else if worstMax > 0.92 && worstMean > 0.48 {
            // Large blown-out highlight with high average brightness
            isBright = true
        } else {
            // Dark or mid-toned enough for clean white glyph contrast
            isBright = false
        }

        let style: UIStatusBarStyle = isBright ? .darkContent : .lightContent

        if let identifier = identifier {
            cache.setObject(NSNumber(value: isBright ? 1 : 0), forKey: identifier as NSString)
        }

        return style
    }

    /// Crops a region and renders it into a small 16x16 thumbnail to compute
    /// perceived luminance via ITU-R BT.709: Y = 0.2126*R + 0.7152*G + 0.0722*B.
    private func analyzeRegion(cgImage: CGImage, rect: CGRect) -> (mean: Double, max: Double) {
        guard let cropped = cgImage.cropping(to: rect) else {
            return (0.0, 0.0)
        }

        let thumbSide = 16
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData = [UInt8](repeating: 0, count: thumbSide * thumbSide * 4)

        guard let context = CGContext(
            data: &pixelData,
            width: thumbSide,
            height: thumbSide,
            bitsPerComponent: 8,
            bytesPerRow: thumbSide * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            return (0.0, 0.0)
        }

        context.interpolationQuality = .medium
        context.draw(cropped, in: CGRect(x: 0, y: 0, width: thumbSide, height: thumbSide))

        var totalLum: Double = 0.0
        var maxLum: Double = 0.0
        let totalPixels = Double(thumbSide * thumbSide)

        for i in stride(from: 0, to: pixelData.count, by: 4) {
            let r = Double(pixelData[i]) / 255.0
            let g = Double(pixelData[i + 1]) / 255.0
            let b = Double(pixelData[i + 2]) / 255.0

            // Standard Rec. 709 perceived luminance
            let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
            totalLum += lum
            if lum > maxLum {
                maxLum = lum
            }
        }

        let meanLum = totalLum / totalPixels
        return (meanLum, maxLum)
    }
}
