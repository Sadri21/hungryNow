//
//  NetworkErrorView.swift
//  hungrynow
//
//  Screen 09 — Connection problem / Service unavailable.
//  Translated from vault mockup `screen-09-network-error.html`, `prototype.js`, and `redesign.css`.
//

import SwiftUI

/// The two copy variants for Screen 09 per HIG and vault specs:
/// - Offline: connection is down, action is to reconnect.
/// - Service Unavailable: device is connected, but backend/Places/Gemini service failed.
enum NetworkErrorVariant: Equatable {
    case offline
    case serviceUnavailable

    var eyebrow: String {
        switch self {
        case .offline:
            return "THE SEARCH IS ON PAUSE"
        case .serviceUnavailable:
            return "A BRIEF INTERRUPTION"
        }
    }

    var title: String {
        switch self {
        case .offline:
            return "You’re offline."
        case .serviceUnavailable:
            return "The search couldn’t finish."
        }
    }

    var body: String {
        switch self {
        case .offline:
            return "Reconnect to Wi-Fi or mobile data, then try again."
        case .serviceUnavailable:
            return "Restaurant recommendations are temporarily unavailable. Please try again in a moment."
        }
    }
}

/// Screen 09 — Retryable network/service failure with "Try again" and "Back to Home" actions.
struct NetworkErrorView: View {

    var variant: NetworkErrorVariant = .offline
    var locationName: String?

    let onRetry: () -> Void
    let onHome: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geo in
            let isCompact = geo.size.height < 740

            VStack(spacing: 0) {
                // Top App Bar
                AppBar(locationName: locationName ?? "Near you")
                    .padding(.horizontal, Metrics.space5)
                    .padding(.top, Metrics.space1)

                // 1. Illustration slot filling available height
                illustrationArea

                // 2. Heading & Body sitting at the bottom above footer
                VStack(alignment: .leading, spacing: 0) {
                    Text(variant.eyebrow)
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1.4)
                        .foregroundColor(Color.text2)
                        .padding(.bottom, isCompact ? 8 : 12)

                    Text(variant.title)
                        .font(.system(size: isCompact ? 30 : 36, weight: .bold))
                        .tracking(-1.2)
                        .lineSpacing(2)
                        .foregroundColor(Color.text)

                    Text(variant.body)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color.text2)
                        .lineSpacing(3)
                        .padding(.top, isCompact ? 10 : 14)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Metrics.space5)
                .padding(.bottom, isCompact ? 12 : 20)

                // 3. Pinned footer without hairline divider per redesign.css .screen-network
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

    private var illustrationArea: some View {
        HStack {
            Spacer()
            Image("state-network-error-illustration")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, Metrics.space5)
                .padding(.vertical, 8)
                .accessibilityHidden(true)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 8) {
            PrimaryButton(
                title: "Try again",
                trailingGlyph: .reload,
                action: onRetry
            )

            // Text button: ChevronLeftGlyph + "Back to Home"
            Button(action: onHome) {
                HStack(spacing: 8) {
                    AppGlyph.chevronLeft.image(size: 14, color: Color.heroText)

                    Text("Back to Home")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color.heroText)
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Metrics.space5)
        .padding(.top, 16)
        .padding(.bottom, Metrics.space4)
        .background(Color.bg)
    }
}

#Preview("Offline - Light") {
    NetworkErrorView(
        variant: .offline,
        locationName: "Seminyak, Bali",
        onRetry: {},
        onHome: {}
    )
    .preferredColorScheme(.light)
}

#Preview("Service Unavailable - Light") {
    NetworkErrorView(
        variant: .serviceUnavailable,
        locationName: nil,
        onRetry: {},
        onHome: {}
    )
    .preferredColorScheme(.light)
}

#Preview("Offline - Dark") {
    NetworkErrorView(
        variant: .offline,
        locationName: "Seminyak, Bali",
        onRetry: {},
        onHome: {}
    )
    .preferredColorScheme(.dark)
}
