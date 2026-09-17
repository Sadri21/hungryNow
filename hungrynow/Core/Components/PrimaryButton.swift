//
//  PrimaryButton.swift
//  hungrynow
//
//  The app's primary action pill. One pill, every screen.
//

import SwiftUI

/// Filled pomegranate, full width, optional leading glyph.
///
/// Shared rather than redrawn per screen: screens 02, 04 and 06 differ only in label and
/// glyph, and the mockups treat `.btn-primary` as one class for exactly that reason.
///
/// **Sized by its padding, not by a fixed height**, so the label can grow with Dynamic Type
/// and the pill grows with it. `Metrics.controlHeight` is the floor. At the default text
/// size that lands on ~50pt, which is the platform norm — the previous version scaled the
/// mockup's numbers and came out 75-84pt depending on device.
///
/// **Buttons never wrap.** A two-line pill reads as a broken control, so the label is one
/// line with a 0.85 floor. A label that still doesn't fit is too long as COPY — shrinking
/// type is not a licence for it.
struct PrimaryButton: View {
    let title: String

    var glyph: AppGlyph?
    var trailingGlyph: AppGlyph?
    var trailingSystemImage: String?

    let action: () -> Void

    /// The glyph tracks the label's size, so the pair stays optically matched at every
    /// Dynamic Type setting instead of the icon shrinking away from bigger text.
    @ScaledMetric(relativeTo: .headline) private var glyphSize: CGFloat = 18

    var body: some View {
        Button(action: action) {
            HStack(spacing: Metrics.space2) {
                if let glyph {
                    glyph.image(size: glyphSize, color: Color.onHero)
                }

                Text(title)
                    .font(AppFont.controlLabel)
                    .foregroundColor(Color.onHero)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                if let trailingGlyph {
                    Spacer()
                    trailingGlyph.image(size: glyphSize, color: Color.onHero)
                } else if let trailingSystemImage {
                    Spacer()
                    Image(systemName: trailingSystemImage)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color.onHero)
                }
            }
            .padding(.vertical, Metrics.space4)
            .padding(.horizontal, Metrics.margin)
            .frame(maxWidth: .infinity, minHeight: Metrics.controlHeight)
            .background(Color.heroSurface)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerSmall, style: .continuous))
            // CSS: inset 0 1px 0 rgba(255,255,255,.18) — a top-edge highlight, not an
            // outline, so it fades out well before the bottom of the pill.
            .overlay(
                RoundedRectangle(cornerRadius: Metrics.cornerSmall, style: .continuous).strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.white.opacity(0)],
                        startPoint: .top,
                        endPoint: .center
                    ),
                    lineWidth: Metrics.hairline
                )
            )
            .shadow(
                color: Color.heroSurface.opacity(0.38),
                radius: Metrics.space2,
                x: 0,
                y: Metrics.space1 + 2
            )
        }
        .buttonStyle(.plain)
    }
}
