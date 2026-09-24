//
//  WelcomeView.swift
//  hungrynow
//
//  Screen 02 — Welcome + location purpose.
//  Translated from the redesign mockup `output/mockups/screen-02-welcome.html`.
//

import CoreLocation
import SwiftUI

/// Welcome and the location pre-prompt are ONE screen.
/// Features a restaurant storefront banner above clear copy explaining why location is required.
struct WelcomeView: View {

    /// Runs once the system location alert has been answered.
    let onContinue: (CLAuthorizationStatus) -> Void

    @StateObject private var viewModel = WelcomeViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Top restaurant banner
                topArtBanner(screenHeight: geo.size.height)
                    .background(Color.elevated.ignoresSafeArea(edges: .top))

                // Middle copy and purpose section
                VStack(alignment: .leading, spacing: 0) {
                    Text("A GOOD MEAL STARTS HERE")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1.4)
                        .foregroundColor(Color.text2)

                    Text("Less deciding.\nMore eating.")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(Color.text)
                        .lineSpacing(2)
                        .padding(.top, Metrics.space2 + 2)

                    Text("Somewhere new? Find one good place to eat, right around you.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.text2)
                        .lineSpacing(3)
                        .padding(.top, Metrics.space3)

                    // Hairline divider and location purpose
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.hairline)
                            .frame(height: 1)
                            .padding(.top, Metrics.space5)

                        HStack(alignment: .top, spacing: Metrics.space3) {
                            Image("glyph-location-pin")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color.text2)
                                .padding(.top, 2)
                                .accessibilityHidden(true)

                            Text("Your location helps find restaurants within walking distance.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color.text2)
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, Metrics.space4)
                    }
                }
                .padding(.horizontal, Metrics.space5)
                .padding(.top, Metrics.space5)

                Spacer(minLength: Metrics.space3)

                // Bottom CTA & note
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

    // MARK: - Top Banner

    private func topArtBanner(screenHeight: CGFloat) -> some View {
        let illustrationHeight = min(max(screenHeight * 0.28, 170), 248)

        return VStack(spacing: 0) {
            // Wordmark and tagline bar
            HStack(alignment: .center) {
                HStack(spacing: 0) {
                    Text("hungry")
                        .foregroundColor(Color.text)
                    Text("now")
                        .foregroundColor(Color.heroSurface)
                    Circle()
                        .fill(Color.heroSurface)
                        .frame(width: 5, height: 5)
                        .padding(.leading, 2)
                        .padding(.bottom, 2)
                }
                .font(.system(size: 22, weight: .bold))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("hungrynow")

                Spacer()

                Text("Good food.\nLess fuss.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.text2)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, Metrics.space5)
            .padding(.top, Metrics.space2)
            .padding(.bottom, Metrics.space2)

            // Rounded café illustration
            Image("welcome-rounded-cafe")
                .resizable()
                .scaledToFit()
                .frame(height: illustrationHeight)
                .frame(maxWidth: .infinity)
                .padding(.bottom, Metrics.space2)
                .accessibilityHidden(true)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: Metrics.space3) {
            PrimaryButton(
                title: "Continue",
                trailingGlyph: .directions
            ) {
                viewModel.requestLocationPermission(completion: onContinue)
            }
            .disabled(viewModel.isRequestingPermission)

            Text("Location permission comes next")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.text2)
        }
        .padding(.horizontal, Metrics.space5)
        .padding(.bottom, Metrics.space4)
    }
}

#Preview {
    WelcomeView(onContinue: { _ in })
        .preferredColorScheme(.light)
}
