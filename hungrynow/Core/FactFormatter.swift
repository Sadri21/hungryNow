//
//  FactFormatter.swift
//  hungrynow
//
//  The number-formatting rule. Every number the app shows goes through here.
//

import Foundation

/// Distance, rating and price tier, formatted once and in one place.
///
/// **Never interpolate a number into a string at a call site.** 7 of the 8 collected UI
/// references got this wrong, and it bites hardest in this app's actual market:
/// Indonesian locale uses a comma as the decimal separator, so `"\(rating)"` renders
/// "4.7" where the device would write "4,7". String interpolation always produces the
/// C locale.
///
/// **Units are metric by product decision, not by locale.** `unitOptions = .providedUnit`
/// is doing real work: the default `.naturalScale` would render miles on a US-locale
/// device. The user is a tourist in Indonesia and the surrounding signage is in metres —
/// and screen 08 already says "1.5 km", so a locale-flipped screen 06 would have the two
/// disagreeing two screens apart. Only the SEPARATOR follows the locale.
enum FactFormatter {

    /// "400 m" under a kilometre, "1.5 km" over it.
    ///
    /// Rounded to the nearest 10 m below 1 km. A Places coordinate plus a phone's own fix
    /// is not accurate to the metre, so "437 m" claims a precision neither input has.
    static func distance(metres: Double) -> String {
        let measurement: Measurement<UnitLength>
        let fractionDigits: Int

        if metres < 1000 {
            measurement = Measurement(value: (metres / 10).rounded() * 10, unit: .meters)
            fractionDigits = 0
        } else {
            measurement = Measurement(value: metres / 1000, unit: .kilometers)
            fractionDigits = 1
        }

        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .medium
        formatter.numberFormatter = decimalFormatter(fractionDigits: fractionDigits)
        return formatter.string(from: measurement)
    }

    /// Formats a count using compact notation: "1k", "1.5k", "1.53k" (up to 2 decimals),
    /// or plain integer if under 1,000.
    static func compactCount(_ count: Int) -> String {
        guard count >= 1000 else {
            return "\(count)"
        }

        let value: Double
        let suffix: String
        if count >= 1_000_000 {
            value = Double(count) / 1_000_000.0
            suffix = "M"
        } else {
            value = Double(count) / 1000.0
            suffix = "k"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        let formattedNumber = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
        return "\(formattedNumber)\(suffix)"
    }

    /// "4.7" — always one decimal place.
    static func ratingValue(_ value: Double) -> String {
        decimalFormatter(fractionDigits: 1).string(from: value as NSNumber) ?? "—"
    }

    /// "4.7" — always one decimal place.
    ///
    /// One place, padded: Places returns 4.0 as often as 4.7, and "4" beside "4.7" in the
    /// same column reads as a different kind of number rather than the same one.
    /// If `count` is provided and > 0, appends the compact review count, e.g. "4.7 (1.53k)".
    static func rating(_ value: Double, count: Int? = nil) -> String {
        let ratingText = ratingValue(value)
        guard let count = count, count > 0 else {
            return ratingText
        }
        return "\(ratingText) (\(compactCount(count)))"
    }

    /// Google's `price_level` 1...4 as "Rp", "Rp Rp", ...
    static func priceTier(_ level: Int) -> String? {
        guard (1...4).contains(level) else { return nil }
        return Array(repeating: "Rp", count: level).joined(separator: " ")
    }

    /// Price range for per-person display on Screen 06 (e.g. "Rp50k–150k").
    static func priceRange(forLevel level: Int) -> String {
        switch level {
        case 1: return "<Rp50k"
        case 2: return "Rp50k–150k"
        case 3: return "Rp150k–300k"
        case 4: return "Rp300k+"
        default: return "Rp50k–150k"
        }
    }

    private static func decimalFormatter(fractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter
    }
}
