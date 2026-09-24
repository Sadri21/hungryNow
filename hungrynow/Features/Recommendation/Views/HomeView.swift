//
//  HomeView.swift
//  hungrynow
//
//  Screen 04 — Home, idle.
//  Translated from the vault redesign mockup `output/mockups/screen-04-home.html` and `redesign.css`.
//

import SwiftUI

/// The one-screen, one-button idle state matching Screen 04 redesign.
/// Features the brand wordmark, location status, time-to-eat headline,
/// table-setting clock artwork, service line, and "I'm hungry" action button.
struct HomeView: View {

    /// The resolved place name for the app bar's chip, e.g. "Seminyak, Bali".
    /// Falls back to "Near you" when nil, matching Screen 04 spec.
    var locationName: String?

    let onFindPlace: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Top App Bar: Wordmark leading, location status trailing
                AppBar(locationName: locationName)
                    .padding(.horizontal, Metrics.space5)
                    .padding(.top, Metrics.space1)

                // Main Screen 04 content
                mainContent(screenHeight: geo.size.height)

                // Pinned footer action button
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

    // MARK: - Main Content

    private func mainContent(screenHeight: CGFloat) -> some View {
        let isCompact = screenHeight < 740
        let clockSide: CGFloat = min(280, isCompact ? 200 : 280)

        return VStack(alignment: .leading, spacing: 0) {
            // 1. Heading
            VStack(alignment: .leading, spacing: 6) {
                Text("GOOD FOOD IS CLOSE")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(1.4)
                    .foregroundColor(Color.text2)

                (
                    Text("Hungry?\n")
                        .foregroundColor(Color.text)
                    +
                    Text("It’s time to eat.")
                        .foregroundColor(Color.heroSurface)
                )
                .font(.system(size: isCompact ? 38 : 44, weight: .bold))
                .tracking(-1.5)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Metrics.space5)
            .padding(.top, isCompact ? 8 : 16)

            Spacer(minLength: 12)

            // 2. Table Setting (Clock Illustration)
            HStack {
                Spacer()
                Image("home-rounded-clock-setting")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: clockSide, maxHeight: clockSide)
                    .accessibilityHidden(true)
                Spacer()
            }
            .padding(.horizontal, Metrics.space5)

            Spacer(minLength: 12)

            // 3. Bottom Information & Service Line
            VStack(alignment: .leading, spacing: 0) {
                Text("One good restaurant.\nA few local specialties. You choose.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.text2)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                // Service Line
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.hairline)
                        .frame(height: 1)
                        .padding(.top, Metrics.space4)

                    HStack {
                        HStack(spacing: 6) {
                            AppGlyph.walkingPerson.image(size: 16, color: Color.text2)
                                .accessibilityHidden(true)

                            Text("Within walking distance")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Color.text2)
                        }

                        Spacer()

                        Text("Just one tap")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color.text2)
                    }
                    .padding(.top, 14)
                }
            }
            .padding(.horizontal, Metrics.space5)
            .padding(.bottom, 12)
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Footer

    private var footer: some View {
        PrimaryButton(
            title: "I’m hungry",
            trailingGlyph: .cutlery,
            action: onFindPlace
        )
        .padding(.horizontal, Metrics.space5)
        .padding(.top, 12)
        .padding(.bottom, Metrics.space4)
    }
}

#Preview("Light - Idle") {
    HomeView(onFindPlace: {})
        .preferredColorScheme(.light)
}

#Preview("Light - Location Resolved") {
    HomeView(locationName: "Seminyak, Bali", onFindPlace: {})
        .preferredColorScheme(.light)
}

#Preview("Dark - Location Resolved") {
    HomeView(locationName: "Seminyak, Bali", onFindPlace: {})
        .preferredColorScheme(.dark)
}
