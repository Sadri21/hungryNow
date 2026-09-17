//
//  LocationOffView.swift
//  hungrynow
//
//  Screen 07 — Location off (Permission denied).
//  Translated from vault mockup `screen-07-permission-denied.html` and `redesign.css`.
//

import SwiftUI

/// Screen 07 — The unrecoverable location off state.
/// Shows step-by-step guidance to enable location in iOS Settings, with a deep link.
struct LocationOffView: View {

    /// Callback to check if permission has been granted, e.g. after returning from Settings.
    var onCheckPermission: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geo in
            let isCompact = geo.size.height < 740

            VStack(spacing: 0) {
                // Top App Bar with pomegranate "Location off" status
                AppBar(locationName: "Location off")
                    .padding(.horizontal, Metrics.space5)
                    .padding(.top, Metrics.space1)

                // Scrollable main content for compact height safety
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // 1. Flexible Illustration slot
                        illustrationArea(screenHeight: geo.size.height, isCompact: isCompact)

                        // 2. Heading & Body
                        VStack(alignment: .leading, spacing: 0) {
                            Text("FIRST, A STARTING POINT")
                                .font(.system(size: 13, weight: .bold))
                                .tracking(1.4)
                                .foregroundColor(Color.text2)
                                .padding(.bottom, isCompact ? 12 : 16)

                            Text("Location is\nturned off.")
                                .font(.system(size: isCompact ? 32 : 36, weight: .bold))
                                .tracking(-1.2)
                                .lineSpacing(2)
                                .foregroundColor(Color.text)

                            Text("Turn on location so HungryNow can find restaurants around you.")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color.text2)
                                .lineSpacing(3)
                                .padding(.top, isCompact ? 14 : 20)
                        }

                        // 3. Numbered steps
                        stepsList
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
            onCheckPermission?()
        }
        .onChange(of: colorScheme) { newScheme in
            StatusBarStyleManager.shared.setStyle(for: newScheme)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            onCheckPermission?()
        }
    }

    // MARK: - Illustration Area

    private func illustrationArea(screenHeight: CGFloat, isCompact: Bool) -> some View {
        let minHeight: CGFloat = isCompact ? 120 : 160
        let targetHeight: CGFloat = min(max(screenHeight * 0.24, minHeight), 220)
        let scale: CGFloat = isCompact ? 1.08 : 1.14

        return HStack {
            Spacer()
            Image("state-location-off-illustration")
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

    // MARK: - Steps List

    private var stepsList: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.hairline)
                .frame(height: 1)

            // Step 01
            HStack(alignment: .top, spacing: 16) {
                Text("01")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color.heroText)

                Text("Open Settings, then HungryNow.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.text)
                    .lineSpacing(2)

                Spacer()
            }
            .padding(.vertical, 16)

            Rectangle()
                .fill(Color.hairline)
                .frame(height: 1)

            // Step 02
            HStack(alignment: .top, spacing: 16) {
                Text("02")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color.heroText)

                Text("Choose Location →\nWhile Using the App.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.text)
                    .lineSpacing(2)

                Spacer()
            }
            .padding(.vertical, 16)

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

            PrimaryButton(
                title: "Open Settings",
                trailingGlyph: .settings,
                action: openSettings
            )
            .padding(.horizontal, Metrics.space5)
            .padding(.top, 16)
            .padding(.bottom, Metrics.space4)
        }
        .background(Color.bg)
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview("Location Off - Light") {
    LocationOffView()
        .preferredColorScheme(.light)
}

#Preview("Location Off - Dark") {
    LocationOffView()
        .preferredColorScheme(.dark)
}
