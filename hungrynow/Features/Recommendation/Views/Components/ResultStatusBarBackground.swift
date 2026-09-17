//
//  ResultStatusBarBackground.swift
//  hungrynow
//
//  Screen 06 — Status bar backdrop covering clock, Dynamic Island, and battery
//  with Color.bg and a hairline divider as the hero photo scrolls away.
//

import SwiftUI

/// Covers the status bar area (clock, network, battery, Dynamic Island) with an opaque background
/// and hairline divider once the hero photo scrolls out of view.
struct ResultStatusBarBackground: View {
    let topInset: CGFloat
    let width: CGFloat
    let opacity: Double

    var body: some View {
        VStack(spacing: 0) {
            Color.bg
                .frame(width: width, height: topInset)

            Color.hairline
                .frame(width: width, height: Metrics.hairline)
        }
        .frame(width: width, height: topInset + Metrics.hairline, alignment: .top)
        .opacity(opacity)
        .animation(.easeInOut(duration: 0.15), value: opacity)
        .allowsHitTesting(false)
    }
}
