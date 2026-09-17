//
//  NoResultsView.swift
//  hungrynow
//
//  Screen 08 — Nothing nearby (404 no_results).
//  Translated from vault mockup `screen-08-no-results.html` and `redesign.css`.
//

import SwiftUI

/// Screen 08 — Framed as an empty state rather than an error: nothing broke,
/// there are simply no restaurants within the 1.5 km search radius.
struct NoResultsView: View {

    var locationName: String?
    let onRetry: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geo in
            let isCompact = geo.size.height < 740

            VStack(spacing: 0) {
                // Top App Bar
                AppBar(locationName: locationName ?? "Near you")
                    .padding(.horizontal, Metrics.space5)
                    .padding(.top, Metrics.space1)

                // Main content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // 1. Flexible Illustration slot
                        illustrationArea(screenHeight: geo.size.height, isCompact: isCompact)

                        // 2. Heading & Body
                        VStack(alignment: .leading, spacing: 0) {
                            Text("A LITTLE FARTHER AFIELD")
                                .font(.system(size: 13, weight: .bold))
                                .tracking(1.4)
                                .foregroundColor(Color.text2)
                                .padding(.bottom, isCompact ? 12 : 16)

                            Text("No restaurants\nnearby.")
                                .font(.system(size: isCompact ? 32 : 36, weight: .bold))
                                .tracking(-1.2)
                                .lineSpacing(2)
                                .foregroundColor(Color.text)

                            Text("No restaurants turned up nearby. Try again when you’re closer to town or another food spot.")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color.text2)
                                .lineSpacing(3)
                                .padding(.top, isCompact ? 14 : 20)
                        }

                        // 3. Radius callout
                        radiusCallout
                            .padding(.top, isCompact ? 20 : 28)
                    }
                    .padding(.horizontal, Metrics.space5)
                    .padding(.top, isCompact ? 16 : 28)
                    .padding(.bottom, 24)
                }

                // 4. Pinned footer with top hairline
                footer
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.bg.ignoresSafeArea())
        }
        .onAppear {
            StatusBarStyleManager.shared.setStyle(for: colorScheme)
        }
        .onChange(of: colorScheme) { newScheme in
            StatusBarStyleManager.shared.setStyle(for: newScheme)
        }
    }

    // MARK: - Illustration Area

    private func illustrationArea(screenHeight: CGFloat, isCompact: Bool) -> some View {
        let minHeight: CGFloat = isCompact ? 120 : 160
        let targetHeight: CGFloat = min(max(screenHeight * 0.24, minHeight), 220)
        let scale: CGFloat = isCompact ? 1.08 : 1.14

        return HStack {
            Spacer()
            Image("state-no-results-illustration")
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .frame(height: targetHeight)
                .accessibilityHidden(true)
            Spacer()
        }
        .frame(minHeight: minHeight)
        .padding(.bottom, isCompact ? 16 : 24)
    }

    // MARK: - Radius Callout

    private var radiusCallout: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.hairline)
                .frame(height: 1)

            HStack(spacing: 12) {
                Image("glyph-location-pin")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.text2)

                Text("1.5 km")
                    .font(.system(size: 28, weight: .bold))
                    .tracking(-1)
                    .foregroundColor(Color.text)

                Text("searched around\nyour location")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.text2)
                    .lineSpacing(2)

                Spacer()
            }
            .padding(.vertical, 20)

            Rectangle()
                .fill(Color.hairline)
                .frame(height: 1)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.hairline)
                .frame(height: 1)

            VStack(spacing: 12) {
                PrimaryButton(
                    title: "Try again",
                    trailingGlyph: .reload,
                    action: onRetry
                )

                Text("Search again from your current location")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.text2)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Metrics.space5)
            .padding(.top, 16)
            .padding(.bottom, Metrics.space4)
        }
        .background(Color.bg)
    }
}

#Preview("No Results - Light") {
    NoResultsView(locationName: "Seminyak, Bali", onRetry: {})
        .preferredColorScheme(.light)
}

#Preview("No Results - Dark") {
    NoResultsView(locationName: nil, onRetry: {})
        .preferredColorScheme(.dark)
}
