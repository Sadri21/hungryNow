//
//  PlaceDetailsView.swift
//  hungrynow
//
//  Screen 06A — Restaurant details. Reusable full-screen destination.
//  Translated from the vault mockup `output/mockups/screen-06a-place-details.html`.
//

import SwiftUI
import UIKit
import GooglePlacesSwift

/// Screen 06A: In-App Place Details destination.
/// Leads with HungryNow recommendation context ("Why this one", reason, plate illustration, Directions action),
/// followed by a bordered provider region ("Place information") with Google Maps attribution,
/// photos, overview contact/hours, and reviews breakdown powered directly by GooglePlacesSwift.
struct PlaceDetailsView: View {
    let item: PlaceDetailItem
    var heroImages: [UIImage] = []

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    @State private var isScrolled: Bool = false
    @State private var placeQuery: PlaceDetailsQuery
    @State private var loadError: String? = nil
    @State private var innerContentHeight: CGFloat = 1050

    init(item: PlaceDetailItem, heroImages: [UIImage] = []) {
        self.item = item
        self.heroImages = heroImages
        let rawId = (item.placeId ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let id = rawId.hasPrefix("places/") ? String(rawId.dropFirst("places/".count)) : rawId
        print("📍 [PlaceDetailsView] init item: '\(item.name)', raw placeId: '\(rawId)', normalized: '\(id)'")
        self._placeQuery = State(initialValue: PlaceDetailsQuery(identifier: .placeID(id)))
        if id.isEmpty {
            self._loadError = State(initialValue: "No placeId provided for \(item.name)")
        }
    }

    /// Resolves top safe area inset for consistent header spacing
    private var safeAreaTop: CGFloat {
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }),
           let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first {
            let inset = window.safeAreaInsets.top
            if inset > 0 { return inset }
        }
        return 59
    }

    var body: some View {
        GeometryReader { geo in
            let topInset = safeAreaTop

            ZStack(alignment: .top) {
                // Background fills entire screen
                Color.bg
                    .ignoresSafeArea(.all)

                // Main Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Spacing for custom top app bar
                        Spacer()
                            .frame(height: topInset + 44)

                        // 1. HungryNow Recommendation Context
                        recommendationContextSection(width: geo.size.width)

                        // 2. Provider Shell ("Place information") or Error State
                        if let error = loadError {
                            errorStateView(message: error)
                        } else {
                            providerShellSection
                        }

                        // Bottom padding for comfortable scrolling
                        Spacer()
                            .frame(height: 48)
                    }
                    .frame(width: geo.size.width)
                    .trackScrollOffset { offset in
                        let scrolled = offset >= 36
                        if self.isScrolled != scrolled {
                            self.isScrolled = scrolled
                        }
                    }
                }

                // Sticky Top App Bar
                topAppBar(topInset: topInset, width: geo.size.width)
                    .zIndex(100)
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            StatusBarStyleManager.shared.setStyle(for: colorScheme)
        }
        .onChange(of: colorScheme) { newScheme in
            StatusBarStyleManager.shared.setStyle(for: newScheme)
        }
    }

    // MARK: - Top App Bar

    private func topAppBar(topInset: CGFloat, width: CGFloat) -> some View {
        VStack(spacing: 0) {
            // Status bar spacer
            Color.clear
                .frame(height: topInset)

            HStack(spacing: 12) {
                // Back Button (Chevron Left)
                Button(action: {
                    dismiss()
                }) {
                    AppGlyph.chevronLeft.image(size: 20, color: Color.text)
                        .offset(x: -1)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back to recommendation")

                Spacer()

                // Centered Collapsible Title: reveals after 36pt scroll
                Text("Restaurant details")
                    .font(AppFont.barTitle)
                    .foregroundColor(Color.text)
                    .opacity(isScrolled ? 1.0 : 0.0)

                Spacer()

                // Balanced spacer matching back button width
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 8)
            .frame(height: 44)

            // Bottom hairline: reveals after 36pt scroll
            Color.hairline
                .frame(height: 1)
                .opacity(isScrolled ? 1.0 : 0.0)
        }
        .animation(.easeInOut(duration: 0.16), value: isScrolled)
        .frame(width: width)
        .background(
            Color.bg
                .opacity(isScrolled ? 1.0 : 0.95)
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - 1. HungryNow Recommendation Context

    private func recommendationContextSection(width: CGFloat) -> some View {
        ZStack(alignment: .topTrailing) {
            // Plate & Clock Illustration: 16pt right inset, 14pt top
            Image("home-rounded-clock-setting")
                .resizable()
                .scaledToFit()
                .frame(width: 108, height: 108)
                .padding(.trailing, 16)
                .padding(.top, 14)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                // Heading: "Why this one" (hierarchy carries context without extra eyebrow)
                Text("Why this one")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.text)
                    .frame(maxWidth: 245, alignment: .leading)
                    .padding(.bottom, 12)

                // Recommendation reason: constrained to preserve 32pt gap to illustration
                Text(item.reason)
                    .font(AppFont.bodyText)
                    .foregroundColor(Color.text2)
                    .lineSpacing(3)
                    .frame(maxWidth: max(0, width - 180), alignment: .leading)
                    .padding(.bottom, 20)

                // Primary Directions Action
                PrimaryButton(
                    title: "Directions",
                    trailingSystemImage: "location.fill",
                    action: { openDirections() }
                )
                .accessibilityLabel("Get directions to \(item.name)")
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bg)
        .overlay(alignment: .bottom) {
            Color.hairline.frame(height: 1)
        }
    }

    // MARK: - Places Theme

    private var placesTheme: PlacesMaterialTheme {
        var theme = PlacesMaterialTheme()
        theme.color.surface = Color.elevated
        theme.color.onSurface = Color.text
        theme.color.onSurfaceVariant = Color.text2
        theme.color.primary = Color.heroText
        theme.color.primaryContainer = Color.heroFill
        theme.color.onPrimaryContainer = Color.heroText
        theme.color.outlineDecorative = Color.hairline
        return theme
    }

    // MARK: - 2. Provider Shell ("Place information")

    private var providerShellSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Provider Header: Title
            VStack(alignment: .leading, spacing: 2) {
                Text("Place information")
                    .font(AppFont.listTitle)
                    .foregroundColor(Color.text)

                Text("Photos, hours and reviews")
                    .font(AppFont.fineprint)
                    .foregroundColor(Color.text2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .frame(height: 60)
            .background(Color.elevated)
            .overlay(alignment: .bottom) {
                Color.hairline.frame(height: 1)
            }

            // GooglePlacesSwift.PlaceDetailsView
            // Google owns collage/gallery, photo count, review count, ordering, loading, and attribution.
            GooglePlacesSwift.PlaceDetailsView(
                orientation: .vertical,
                query: $placeQuery,
                configuration: PlaceDetailsConfiguration(
                    content: GooglePlacesSwift.PlaceDetailsView.allContent,
                    theme: placesTheme
                ),
                placeDetailsCallback: { result in
                    if let error = result.error {
                        let detailedMsg = self.formatPlacesError(error)
                        print("❌ [PlaceDetailsView] GooglePlacesSwift error: \(detailedMsg)")
                        self.loadError = detailedMsg
                    } else if let place = result.place {
                        print("✅ [PlaceDetailsView] Loaded place: \(place.displayName ?? ""), placeID: \(place.placeID ?? "")")
                    } else {
                        print("✅ [PlaceDetailsView] GooglePlacesSwift loaded place details successfully!")
                    }
                }
            )
            .frame(maxWidth: .infinity)
            .frame(height: max(380, innerContentHeight))
            .animation(.easeInOut(duration: 0.25), value: innerContentHeight)
            .background(InnerScrollViewManager(contentHeight: $innerContentHeight))
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .background(Color.elevated)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.hairline, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }

    private func formatPlacesError(_ error: any Error) -> String {
        if let placesError = error as? GooglePlacesSwift.PlacesError {
            switch placesError {
            case .network(let message):
                return "Network Error: \(message)"
            case .server(let message):
                return "Server Error: \(message)"
            case .internal(let message):
                return "Internal Error: \(message)"
            case .keyInvalid(let message):
                return "API Key Invalid: \(message)"
            case .keyExpired(let message):
                return "API Key Expired: \(message)"
            case .usageLimitExceeded(let message):
                return "Usage Limit Exceeded: \(message)"
            case .rateLimitExceeded(let message):
                return "Rate Limit Exceeded: \(message)"
            case .deviceRateLimitExceeded(let message):
                return "Device Rate Limit Exceeded: \(message)"
            case .accessNotConfigured(let message):
                return "Access Not Configured: \(message)"
            case .incorrectBundleIdentifier(let message):
                return "Incorrect Bundle ID: \(message)"
            case .location(let message):
                return "Location Error: \(message)"
            case .invalidRequest(let message):
                return "Invalid Request: \(message)"
            @unknown default:
                return "Places Error: \(placesError.localizedDescription)"
            }
        }
        return error.localizedDescription
    }

    // MARK: - Error State View (matching vault screen-06a mockup)

    private func errorStateView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(Color.heroText)

            Text("Details aren’t available")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color.text)

            Text("The place-information limit may have been reached, or the connection was interrupted.")
                .font(AppFont.bodyText)
                .foregroundColor(Color.text2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            #if DEBUG
            Text("Debug: \(message)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            #endif

            Button(action: { dismiss() }) {
                Text("Back to recommendation")
                    .font(AppFont.controlLabel)
                    .foregroundColor(Color.heroText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.heroFill)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.elevated)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.hairline, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }

    // MARK: - Actions

    private func openDirections() {
        if let url = DirectionsLink.appleMaps(
            latitude: item.latitude,
            longitude: item.longitude,
            name: item.name
        ) ?? DirectionsLink.googleMapsPlace(
            placeId: item.placeId,
            name: item.name,
            address: item.address
        ) {
            openURL(url)
        }
    }
}

// MARK: - Preview

#Preview("Place Details") {
    NavigationStack {
        PlaceDetailsView(
            item: PlaceDetailItem(
                name: "Restoran Nasi Kandar Ar Rashid",
                address: "Jl. Sunset Road, Seminyak",
                reason: "A casual spot for a generous plate of rice and curry, with plenty to choose from at the counter.",
                description: "Open-fronted nasi kandar counter with a dozen curries and generous portions.",
                foodCategory: "Nasi Kandar",
                phone: "+62 361 555 0148",
                placeId: "sample_place_id",
                latitude: -8.6913,
                longitude: 115.1682,
                rating: 4.9,
                ratingCount: 1530,
                priceLevel: 2,
                isHero: true
            )
        )
    }
}

// MARK: - Inner Scroll View Manager

/// Introspects GooglePlacesSwift.PlaceDetailsView to:
/// 1. Disable its internal vertical scrolling so only the parent ScrollView handles vertical scrolling.
/// 2. Dynamically measure contentSize.height across all tabs (Overview, Reviews, About)
///    via parent-aware hierarchy traversal, KVO on contentSize, and polling so that all reviews
///    and tab contents are completely visible without clipping.
private struct InnerScrollViewManager: UIViewRepresentable {
    @Binding var contentHeight: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(contentHeight: $contentHeight)
    }

    func makeUIView(context: Context) -> LayoutTriggeringView {
        let view = LayoutTriggeringView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        context.coordinator.setAnchor(view)

        view.onWindowChange = { [weak coordinator = context.coordinator] window in
            if window != nil {
                coordinator?.startPolling()
                coordinator?.scanAndAttach()
            } else {
                coordinator?.stopPolling()
            }
        }

        DispatchQueue.main.async {
            context.coordinator.startPolling()
            context.coordinator.scanAndAttach()
        }
        return view
    }

    func updateUIView(_ uiView: LayoutTriggeringView, context: Context) {
        // Intentionally no-op to avoid triggering view tree scans on scrollOffset changes during scroll
    }

    final class LayoutTriggeringView: UIView {
        var onWindowChange: ((UIWindow?) -> Void)?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            onWindowChange?(window)
        }
    }

    final class Coordinator: NSObject {
        @Binding var contentHeight: CGFloat
        private weak var anchorView: UIView?
        private weak var cachedParentSV: UIScrollView?
        private var observations: [ObjectIdentifier: [NSKeyValueObservation]] = [:]
        private var pollTimer: Timer?
        private var isScanning = false

        init(contentHeight: Binding<CGFloat>) {
            self._contentHeight = contentHeight
            super.init()
        }

        deinit {
            stopPolling()
            for obsList in observations.values {
                for obs in obsList {
                    obs.invalidate()
                }
            }
            observations.removeAll()
        }

        func setAnchor(_ view: UIView) {
            self.anchorView = view
        }

        func startPolling() {
            guard pollTimer == nil else { return }
            // RunLoop.Mode.default automatically pauses this timer while the user is actively scrolling (UITrackingRunLoopMode),
            // completely eliminating timer CPU consumption during drag gestures.
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.scanAndAttach()
            }
            self.pollTimer = timer
        }

        func stopPolling() {
            pollTimer?.invalidate()
            pollTimer = nil
        }

        func scanAndAttach() {
            guard !isScanning else { return }
            isScanning = true
            defer { isScanning = false }

            guard let anchor = anchorView else { return }

            // 1. Locate the enclosing parent UIScrollView (cached after initial discovery)
            var parentSV = cachedParentSV
            if parentSV == nil {
                var curr: UIView? = anchor.superview
                while let v = curr {
                    if let sv = v as? UIScrollView {
                        parentSV = sv
                        break
                    }
                    curr = v.superview
                }
                if parentSV == nil, let window = anchor.window {
                    let all = findAllScrollViews(in: window)
                    parentSV = all.first(where: { anchor.isDescendant(of: $0) })
                        ?? all.max(by: { $0.frame.height < $1.frame.height })
                }
                cachedParentSV = parentSV
            }

            // If the user is actively scrolling the page, skip any scanning to guarantee 120 FPS
            if let parent = parentSV, parent.isDragging || parent.isDecelerating {
                return
            }

            let inners: [UIScrollView]
            if let parent = parentSV {
                inners = findAllScrollViews(in: parent).filter { $0 !== parent }
            } else if let window = anchor.window {
                inners = findAllScrollViews(in: window).filter { $0.frame.height < window.bounds.height * 0.9 }
            } else {
                inners = []
            }

            for sv in inners {
                let id = ObjectIdentifier(sv)
                if observations[id] == nil {
                    // Check if it's the horizontal media/photo strip
                    let isHorizontalStrip = sv.contentSize.width > sv.contentSize.height && sv.contentSize.height < 320
                    if !isHorizontalStrip {
                        sv.isScrollEnabled = false
                        sv.panGestureRecognizer.isEnabled = false
                        sv.bounces = false
                        sv.alwaysBounceVertical = false
                        sv.showsVerticalScrollIndicator = false
                    }

                    var obsList: [NSKeyValueObservation] = []
                    let sizeObs = sv.observe(\.contentSize, options: [.new]) { [weak self] observedSV, _ in
                        self?.handleContentSizeChange(for: observedSV)
                    }
                    obsList.append(sizeObs)

                    if !isHorizontalStrip {
                        let scrollObs = sv.observe(\.isScrollEnabled, options: [.new]) { observedSV, _ in
                            if observedSV.isScrollEnabled {
                                observedSV.isScrollEnabled = false
                                observedSV.panGestureRecognizer.isEnabled = false
                            }
                        }
                        obsList.append(scrollObs)
                    }

                    observations[id] = obsList
                }
            }

            evaluateHeights(inners: inners)
        }

        private func handleContentSizeChange(for sv: UIScrollView) {
            let isHorizontalStrip = sv.contentSize.width > sv.contentSize.height && sv.contentSize.height < 320
            guard !isHorizontalStrip, !sv.isHidden, sv.alpha > 0.05 else { return }

            if sv.isScrollEnabled {
                sv.isScrollEnabled = false
                sv.panGestureRecognizer.isEnabled = false
            }
            sv.bounces = false
            sv.alwaysBounceVertical = false
            sv.showsVerticalScrollIndicator = false

            let targetHeight = sv.contentSize.height
            if targetHeight > 250 {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if abs(self.contentHeight - targetHeight) > 4 {
                        print("📏 [InnerScrollViewManager] Card height evaluated: \(targetHeight) (updated from: \(self.contentHeight))")
                        self.contentHeight = targetHeight
                    }
                }
            }
        }

        private func evaluateHeights(inners: [UIScrollView]) {
            // Filter to active, visible vertical scrollviews
            let verticalScrollViews = inners.filter { sv in
                let isHorizontalStrip = sv.contentSize.width > sv.contentSize.height && sv.contentSize.height < 320
                guard !isHorizontalStrip, !sv.isHidden, sv.alpha > 0.05 else { return false }
                if let window = sv.window {
                    let frameInWindow = sv.convert(sv.bounds, to: window)
                    if frameInWindow.origin.x < -40 || frameInWindow.origin.x > window.bounds.width - 40 {
                        return false
                    }
                }
                return true
            }

            guard let sv = verticalScrollViews.first else { return }
            handleContentSizeChange(for: sv)
        }

        private func findAllScrollViews(in view: UIView) -> [UIScrollView] {
            var results: [UIScrollView] = []
            var queue: [UIView] = [view]
            while !queue.isEmpty {
                let current = queue.removeFirst()
                if let sv = current as? UIScrollView, !(sv is UITextView) {
                    results.append(sv)
                }
                queue.append(contentsOf: current.subviews)
            }
            return results
        }
    }
}
