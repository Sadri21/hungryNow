//
//  ResultFooter.swift
//  hungrynow
//
//  Screen 06 — Bottom action bar with primary Directions button and secondary "Try another" button.
//

import SwiftUI

/// Pinned bottom action bar for Screen 06.
struct ResultFooter: View {
    let directionsURL: URL?
    let onTryAnother: () -> Void

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            Color.hairline.frame(height: 1)

            HStack(spacing: 12) {
                PrimaryButton(
                    title: "Directions",
                    trailingSystemImage: "location.fill",
                    action: { if let directionsURL { openURL(directionsURL) } }
                )
                .disabled(directionsURL == nil)
                .opacity(directionsURL == nil ? 0.4 : 1)

                Button(action: onTryAnother) {
                    AppGlyph.refreshArrows.image(size: 24, color: Color.text)
                        .frame(width: Metrics.controlHeight, height: Metrics.controlHeight)
                        .background(Color.bg)
                        .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerSmall, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: Metrics.cornerSmall, style: .continuous)
                                .stroke(Color.hairline, lineWidth: 1)
                        )
                        .shadow(
                            color: Color.black.opacity(0.12),
                            radius: Metrics.space2,
                            x: 0,
                            y: Metrics.space1 + 2
                        )
                        .contentShape(RoundedRectangle(cornerRadius: Metrics.cornerSmall, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Find another restaurant")
            }
            .padding(.horizontal, Metrics.margin)
            .padding(.top, 12)
            .padding(.bottom, Metrics.space5)
        }
        .background(Color.bg)
    }
}
