//
//  SoftBackground.swift
//  hungrynow
//
//  `.softbg` from the mockups' shared.css — the two blurred accent circles behind
//  every in-app screen (04, 05, 06 and the edge states 07-09).
//

import SwiftUI

/// Shared for the same reason the app bar is: these circles are what stops the
/// in-app screens reading as plain white, and having them on some screens but not
/// others made the flow feel like two different apps.
///
/// **Not used by screen 02**, which draws hard-edged geometry instead — soft blur
/// versus hard shapes is what keeps 02 and 04 from reading as the same screen.
///
/// Positions dodge the middle of the screen deliberately: screen 05's radar and
/// screen 04's illustration both live there.
struct SoftBackground: View {

    /// The container's width. These are ART — proportions, not sizes — so they scale with
    /// the screen. See `MockupArt`.
    let width: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.heroFill)
                .frame(
                    width: MockupArt.width(180, in: width),
                    height: MockupArt.width(180, in: width)
                )
                .blur(radius: MockupArt.width(3, in: width))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(
                    x: MockupArt.width(70, in: width),
                    y: -MockupArt.width(64, in: width)
                )

            Circle()
                .fill(Color.specFill)
                .frame(
                    width: MockupArt.width(130, in: width),
                    height: MockupArt.width(130, in: width)
                )
                .blur(radius: MockupArt.width(3, in: width))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .offset(
                    x: -MockupArt.width(62, in: width),
                    y: -MockupArt.width(120, in: width)
                )
        }
        .clipped()
        .accessibilityHidden(true)
    }
}
