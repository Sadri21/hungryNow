//
//  SecondaryButton.swift
//  hungrynow
//
//  `.secondary` — outlined control matching `redesign.css` and `screen-05-loading.html`.
//

import SwiftUI

/// Outlined button, full width, hairline border, ink text, optional leading chevron.
struct SecondaryButton: View {
    let title: String
    var leadingChevron: Bool = false
    let action: () -> Void

    @ScaledMetric(relativeTo: .headline) private var glyphSize: CGFloat = 18

    var body: some View {
        Button(action: action) {
            HStack(spacing: Metrics.space2) {
                if leadingChevron {
                    AppGlyph.chevronLeft.image(size: glyphSize, color: Color.text)
                }

                Text(title)
                    .font(AppFont.controlLabel)
                    .foregroundColor(Color.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .padding(.vertical, Metrics.space4)
            .padding(.horizontal, Metrics.margin)
            .frame(maxWidth: .infinity, minHeight: Metrics.controlHeight)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: Metrics.cornerSmall, style: .continuous)
                    .stroke(Color.hairline, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: Metrics.cornerSmall, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
