//
//  SearchingView.swift
//  hungrynow
//
//  Screen 05 — Finding a restaurant.
//  Translated from the redesign mockup `output/mockups/screen-05-loading.html`.
//

import SwiftUI
import Lottie

/// Screen 05: The loading state while looking for a nearby restaurant recommendation.
/// Features the restaurant search Lottie animation inside a kitchen ticket card,
/// honest progress stages, the 15-second wait note, and a Cancel button.
struct SearchingView: View {

    /// The app bar's chip, carried over from Home. Absent until the reverse geocode
    /// lands and on every failure path — the same contract as `HomeView`.
    var locationName: String?

    let stage: SearchStage
    let onCancel: () -> Void

    /// The wait note is held back for 3 seconds.
    /// It promises "up to 15 seconds", and on a location-cache hit the search can finish quickly,
    /// so showing it from t=0 would flash an unnecessary warning.
    @State private var showWaitNote = false
    @State private var isPulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geo in
            let column = geo.size.width - Metrics.margin * 2

            ZStack {
                Color.bg
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    AppBar(locationName: locationName)

                    VStack(alignment: .leading, spacing: Metrics.space1) {
                        Text("YOUR NEXT MEAL")
                            .font(AppFont.microLabel)
                            .tracking(Metrics.microTracking)
                            .foregroundColor(Color.text2)

                        Text("Finding your\nkind of place.")
                            .font(AppFont.screenQuestion)
                            .foregroundColor(Color.text)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Metrics.space3)

                    Spacer(minLength: Metrics.space2)

                    // The Ticket Container with the Lottie nearby search animation
                    ticketCard(columnWidth: column)

                    Spacer(minLength: Metrics.space2)

                    VStack(spacing: Metrics.space3) {
                        Text("This can take up to 15 seconds.")
                            .font(AppFont.note)
                            .foregroundColor(Color.text2)
                            .multilineTextAlignment(.center)
                            .opacity(showWaitNote ? 1 : 0)
                            .animation(.easeIn(duration: 0.2), value: showWaitNote)
                            .accessibilityHidden(!showWaitNote)

                        SecondaryButton(
                            title: "Cancel",
                            leadingChevron: true,
                            action: onCancel
                        )
                    }
                    .padding(.top, Metrics.space3)
                }
                .padding(.horizontal, Metrics.margin)
                .padding(.bottom, Metrics.space5)
                .frame(width: geo.size.width)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            showWaitNote = true
        }
        .onAppear {
            StatusBarStyleManager.shared.setStyle(for: colorScheme)
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
        .onChange(of: colorScheme) { newScheme in
            StatusBarStyleManager.shared.setStyle(for: newScheme)
        }
    }

    // MARK: - Ticket Card

    private func ticketCard(columnWidth: CGFloat) -> some View {
        let graphicSide = min(220, columnWidth - Metrics.space5 * 2)

        return VStack(spacing: 0) {
            // Top accent border (4pt berry)
            Rectangle()
                .fill(Color.heroSurface)
                .frame(height: 4)

            VStack(spacing: 0) {
                // Upper art area with quiet map silhouette background
                VStack(spacing: Metrics.space4) {
                    // No ticket header on this screen. The markup carries HUNGRYNOW and the
                    // location, but `redesign.css` hides them here
                    // (`.screen-loading .ticket-head > span { display:none }`) — the app bar
                    // already says both, and the ticket is the art, not a second header.

                    // Lottie restaurant search animation
                    LottiePlayer(
                        name: "hungrynow-nearby-search-v3",
                        loopMode: .loop,
                        isAnimating: !reduceMotion
                    )
                    .frame(width: graphicSide, height: graphicSide)
                    .accessibilityHidden(true)
                }
                .padding(.horizontal, Metrics.space5)
                .padding(.top, Metrics.space5)
                .padding(.bottom, Metrics.space4)
                .frame(maxWidth: .infinity)
                .background(
                    Image("loading-map-background")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.16)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                )
                .clipped()

                // Dashed separator line
                TicketDashedDivider()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                    .foregroundColor(Color.hairline)
                    .frame(height: 1)
                    .padding(.horizontal, Metrics.space5)

                // Status indicator line
                HStack(spacing: Metrics.space3) {
                    Circle()
                        .fill(Color.heroSurface)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isPulsing ? 1.25 : 0.85)
                        .opacity(isPulsing ? 1.0 : 0.45)

                    Text(statusText)
                        .font(AppFont.secondaryLabel)
                        .foregroundColor(Color.text)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                }
                .padding(Metrics.space5)
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.updatesFrequently)
            }
            .background(Color.elevated)
        }
        .clipShape(
            // Top corners only. The bottom edge is torn, not rounded — a rounded corner
            // there would cut the first and last teeth in half.
            AsymmetricRoundedRectangle(
                topLeading: Metrics.cornerSmall,
                topTrailing: Metrics.cornerSmall,
                bottomTrailing: 0,
                bottomLeading: 0
            )
        )
        .overlay(
            AsymmetricRoundedRectangle(
                topLeading: Metrics.cornerSmall,
                topTrailing: Metrics.cornerSmall,
                bottomTrailing: 0,
                bottomLeading: 0
            )
            .stroke(Color.hairline, lineWidth: 1)
        )
        // The perforated tear-off edge (`.ticket:after`), an 8pt zigzag hanging below the
        // card on a 16pt period. Drawn in an overlay aligned to the bottom and pushed
        // fully outside the card, so it adds no height to the ticket itself.
        .overlay(alignment: .bottom) {
            TicketTornEdge(period: 16)
                .fill(Color.elevated)
                .frame(height: 8)
                .offset(y: 8)
        }
    }

    private var statusText: String {
        switch stage {
        case .locating:
            return "Finding where you are"
        case .reading:
            return "Looking for a good local spot"
        }
    }
}

// MARK: - Dashed Divider

/// The ticket's tear-off edge: a row of downward triangles.
///
/// The mockup builds this from two 45-degree linear gradients on a 16px tile
/// (`.ticket:after`), which is a CSS way of drawing a triangle wave. A `Shape` is the
/// direct equivalent and scales cleanly to any width.
private struct TicketTornEdge: Shape {

    /// Width of one tooth, matching the mockup's 16px background tile.
    let period: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // Walk the full width so the final tooth is clipped by the frame rather than
        // leaving a gap when the width is not an exact multiple of the period.
        var x = rect.minX
        while x < rect.maxX {
            path.addLine(to: CGPoint(x: x + period / 2, y: rect.maxY))
            path.addLine(to: CGPoint(x: x + period, y: rect.minY))
            x += period
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct TicketDashedDivider: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

// MARK: - Stages

enum SearchStage: Int, CaseIterable {
    case locating
    case reading

    var label: String {
        switch self {
        case .locating: return "Finding where you are"
        case .reading: return "Looking for a good local spot"
        }
    }
}

// MARK: - Previews

#Preview("Searching - Locating") {
    SearchingView(locationName: "Seminyak, Bali", stage: .locating, onCancel: {})
        .preferredColorScheme(.light)
}

#Preview("Searching - Reading") {
    SearchingView(locationName: "Seminyak, Bali", stage: .reading, onCancel: {})
        .preferredColorScheme(.light)
}
