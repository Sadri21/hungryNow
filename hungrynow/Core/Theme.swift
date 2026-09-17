//
//  Theme.swift
//  hungrynow
//
//  Design tokens shared by every screen.
//
//  COLOUR mirrors the vault's `output/mockups/shared.css` :root block one-to-one — a hex is
//  a hex, so that transfers exactly. SIZING does not: type, spacing and controls are iOS
//  standards, not converted CSS pixels. See `AppFont` and `Metrics` for why, and
//  `MockupArt` for the one category that still scales with the screen.
//

import SwiftUI

// MARK: - Color Tokens

/// Design tokens loaded from the Xcode Asset Catalog (`Assets.xcassets`),
/// supporting dynamic Any (Light) and Dark appearances per the vault mockup specs
/// (`wiki/concepts/visual-identity.md`, `shared.css`, `redesign.css`).
extension Color {
    // MARK: Core Tokens
    static let bg = Color("bg")
    static let elevated = Color("elevated")
    static let text = Color("text")
    static let text2 = Color("text2")

    static let heroSurface = Color("heroSurface")
    static let heroText = Color("heroText")
    static let heroFill = Color("heroFill")

    static let specSurface = Color("specSurface")
    static let specText = Color("specText")
    static let specFill = Color("specFill")

    static let hairline = Color("hairline")

    /// Text and glyphs drawn ON a saturated accent fill. In dark appearance,
    /// this resolves to dark wine-black on bright pomegranate (#F58396) for 7.38:1 contrast.
    static let onHero = Color("onHero")

    // MARK: Semantic Aliases (from wiki/concepts/visual-identity.md)
    static let background = Color.bg
    static let textPrimary = Color.text
    static let textSecondary = Color.text2
    static let heroAccentSurface = Color.heroSurface
    static let heroAccentText = Color.heroText
    static let specialtyAccentSurface = Color.specSurface
    static let specialtyAccentText = Color.specText
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: - Type

/// The app's type scale, as Dynamic Type.
///
/// **iOS sizing is the priority; the mockups are reference, not spec** (Sadri, 2026-09-09).
/// They settle WHAT is on each screen, in what order, and what outranks what. They do not
/// settle how big it is — they are a 242px-wide CSS frame, and a point size is not a CSS
/// pixel.
///
/// What this replaces, and why the old approach was wrong: every screen used to set type as
/// `.system(size: mockupPx * screenWidth / 242)`. Two consequences, both real:
///
/// 1. **Type grew with the screen.** Body text came out 17.8pt on an SE, 18.7pt on a 16 and
///    20.9pt on a Pro Max — where the platform answer is 17pt on all three. A Pro Max
///    became a magnified SE instead of showing more content, which is the opposite of the
///    iOS layout model.
/// 2. **Dynamic Type did nothing at all.** A computed `.system(size:)` ignores the reader's
///    text-size setting, so every accessibility text size was silently a no-op. That is an
///    accessibility failure rather than a style choice, and it is why the vault's
///    "longest-real-string pass at the largest accessibility size" item could never pass.
///
/// Every face here is built on a semantic `Font.TextStyle`, so it scales with the reader's
/// setting. `design: .rounded` keeps SF Rounded, which is the app's typeface (the mockups'
/// `ui-rounded`) — that part of the mockup does carry over, because a typeface is not a size.
///
/// **The mockup's HIERARCHY is preserved, its numbers are not.** The ranking of every
/// element is unchanged; each rank is mapped onto the nearest native style.
enum AppFont {

    /// SF Rounded at a semantic size. Use a named role below rather than calling this
    /// directly, so the scale stays a scale.
    static func rounded(_ style: Font.TextStyle, _ weight: Font.Weight = .regular) -> Font {
        .system(style, design: .rounded).weight(weight)
    }

    // MARK: Roles, largest first

    /// Screen 04's question. `.title` = 28pt.
    static let screenQuestion = rounded(.title, .heavy)

    /// The wordmark on screen 02. `.title2` = 22pt.
    static let wordmark = rounded(.title2, .heavy)

    /// A place name — the hero's title on screen 06. `.title3` = 20pt.
    ///
    /// Real Places names are long ("Restoran Nasi Kandar Ar Rashid" is typical, not a worst
    /// case), which is why this is `.title3` and not `.title2`.
    static let placeName = rounded(.title3, .bold)

    /// App bar title. `.headline` = 17pt, which is what iOS uses for an inline nav title.
    static let barTitle = rounded(.headline, .heavy)

    /// A primary control's label. `.headline` = 17pt — the platform size for a prominent
    /// button.
    static let controlLabel = rounded(.headline, .semibold)

    /// The number in a fact column. `.callout` = 16pt.
    static let factValue = rounded(.callout, .heavy)

    /// A row title in a list. `.subheadline` = 15pt.
    static let listTitle = rounded(.subheadline, .bold)

    /// Running text — the hero's reason, screen 02's tagline and purpose copy.
    /// `.subheadline` = 15pt.
    static let bodyText = rounded(.subheadline)

    /// The lead clause inside a run of body text, same size, heavier.
    static let bodyEmphasis = rounded(.subheadline, .heavy)

    /// A demoted control's label, and screen 05's stage rows. `.subheadline` = 15pt.
    static let secondaryLabel = rounded(.subheadline, .semibold)

    /// A category tag beside a glyph. `.footnote` = 13pt.
    static let tag = rounded(.footnote, .semibold)

    /// An inline text action — screen 06's More / Less. `.footnote` = 13pt.
    static let inlineAction = rounded(.footnote, .bold)

    /// The location chip. `.caption` = 12pt.
    static let chip = rounded(.caption, .semibold)

    /// An explanatory aside. `.caption` = 12pt.
    static let note = rounded(.caption)

    /// An uppercase, tracked micro-label — "PICKED FOR YOU", "ALSO NEARBY", fact captions.
    /// `.caption2` = 11pt. Pair with `Metrics.microTracking`.
    static let microLabel = rounded(.caption2, .bold)

    /// Legal fine print — the photo attribution Google requires. `.caption2` = 11pt.
    ///
    /// Full opacity, deliberately: the mockup sets this at `opacity:.75`, which composites
    /// `text2` to about 3.51:1 where 4.5:1 is required. That is the same bug `shared.css`
    /// warns about in its own comment on `.privacy-note`.
    static let fineprint = rounded(.caption2)
}

// MARK: - Metrics

/// Spacing, control sizes and radii, in real points on a 4pt grid.
///
/// Constant across devices, which is the whole point: a bigger screen shows MORE, not the
/// same thing larger. A thumb is the same size on an SE and a Pro Max, and so is a
/// comfortable reading margin.
enum Metrics {

    /// Content inset. 20pt — Apple's readable-content margin at compact widths.
    ///
    /// The mockups use 22 of 242, i.e. 9% of screen width, which came out at 34-40pt
    /// depending on device and left the app noticeably narrower than native.
    static let margin: CGFloat = 20

    /// The HIG minimum. Never scaled by anything.
    static let tapTarget: CGFloat = 44

    /// A standard filled control's height. Controls are sized by their padding so they grow
    /// with Dynamic Type; this is the floor, not a fixed height.
    static let controlHeight: CGFloat = 50

    /// One point, so a hairline stays a hairline.
    static let hairline: CGFloat = 1

    /// Letter-spacing for an uppercase micro-label. Points, not ems.
    static let microTracking: CGFloat = 0.8

    // MARK: 4pt grid

    static let space1: CGFloat = 4
    static let space2: CGFloat = 8
    static let space3: CGFloat = 12
    static let space4: CGFloat = 16
    static let space5: CGFloat = 24
    static let space6: CGFloat = 32

    // MARK: Radii

    /// The small corner in the app's asymmetric pair.
    static let cornerSmall: CGFloat = 16

    /// The large corner. Bigger than iOS convention on purpose — "one large corner, on the
    /// side facing what the surface overlaps" is part of the app's identity, and a radius is
    /// a shape decision rather than a size one.
    static let cornerLarge: CGFloat = 28
}

// MARK: - Glyph metrics

/// Stroke weight for a glyph drawn as a `Shape`.
enum GlyphMetrics {

    /// A glyph's `stroke-width` in points.
    ///
    /// The mockups author `stroke-width` in **viewBox units on the glyph's own grid**, so it
    /// has to be converted through the grid and the size actually drawn. Passing the raw
    /// number as points overstates it by `grid / size` — the location chip's pin shipped
    /// about 2.4x too heavy exactly that way.
    ///
    /// A bundled imageset carries its own stroke geometry and needs none of this.
    static func stroke(_ strokeWidth: CGFloat, grid: CGFloat = 24, size: CGFloat) -> CGFloat {
        strokeWidth * size / grid
    }
}

// MARK: - Artwork proportions

/// A dimension from the mockup as a fraction of its container's width.
///
/// **ARTWORK ONLY — never type, spacing or controls.** This is the one thing the old
/// screen-width scaling got right, and it has to survive: the supergraphic band, the home
/// illustration and the radar are COMPOSITIONS, not sizes. The band is authored as
/// `height = width x 0.826` (200/242) and its crop at both edges is the entire idea of a
/// supergraphic; freeze it to a point value and it stops bleeding on a wide screen and
/// overflows on a narrow one.
///
/// So the rule is a split: art scales with the screen, everything a reader reads or touches
/// does not.
enum MockupArt {

    /// The mockup phone frame, from `shared.css` `.device` minus its 14px bezel.
    static let frameWidth: CGFloat = 242

    /// `mockupPx` expressed against a real container width.
    static func width(_ mockupPx: CGFloat, in container: CGFloat) -> CGFloat {
        container * (mockupPx / frameWidth)
    }
}
