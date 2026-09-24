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

    /// The rating spoken aloud: "4.3 out of 5".
    ///
    /// VoiceOver reads a comma-decimal locale's "4,3" as a list — "four, three" — so a
    /// 4.3-star place sounds like two numbers. Spelling the separator as a word fixes
    /// that, and "out of 5" restores the scale the star glyph carried visually before
    /// it was hidden from the accessibility tree.
    ///
    /// Takes the already-formatted string rather than the Double so there is one
    /// rounding rule, not two: whatever the column shows is what gets spoken.
    static func spokenRating(_ formattedValue: String) -> String {
        let separator = Locale.current.decimalSeparator ?? "."
        let spoken = formattedValue.replacingOccurrences(of: separator, with: " point ")
        return "Rated \(spoken) out of 5"
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

    /// Per-person price for the fact row, preferring real amounts over a guess.
    ///
    /// **Order matters.** Google's `priceRange` is reported spend with a currency
    /// code, so it is correct anywhere. `priceLevel` is a bare 1...4 ordinal — it
    /// carries no amounts and no currency, so the only honest rendering of it is a
    /// tier, never money.
    ///
    /// This used to map the ordinal onto hardcoded rupiah bands, which meant a
    /// Singapore restaurant displayed "Rp50k–150k": wrong currency, and figures
    /// Google never supplied. Returns nil when there is nothing to say, so the
    /// column can be omitted rather than filled with a default.
    static func price(range: PriceRange?, level: Int?) -> String? {
        if let range, let text = formatted(range) {
            return text
        }
        if let level, (1...4).contains(level) {
            return String(repeating: "$", count: level)
        }
        return nil
    }

    /// "IDR 50,000–75,000", or "IDR 250,000+" when the range is open-ended.
    ///
    /// Grouping separators follow the device locale, but the currency CODE is
    /// Google's, not the device's — the price belongs to the restaurant's country,
    /// so an Indonesian phone in Singapore must still read SGD.
    private static func formatted(_ range: PriceRange) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        formatter.maximumFractionDigits = 0

        func amount(_ value: Int) -> String {
            formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }

        switch (range.start, range.end) {
        case let (start?, end?):
            return "\(range.currency) \(amount(start))–\(amount(end))"
        case let (start?, nil):
            return "\(range.currency) \(amount(start))+"
        case let (nil, end?):
            return "\(range.currency) <\(amount(end))"
        case (nil, nil):
            return nil
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
